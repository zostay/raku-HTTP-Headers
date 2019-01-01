use v6;

package HTTP::Header {

    #| Enumeration of standard headers
    our enum Standard::Name is export(:standard-names)
        # General, Request, Response, Entity Headers
        <
            Cache-Control Connection Date Pragma Trailer Transfer-Encoding
            Upgrade Via Warning

            Accept Accept-Charset Accept-Encoding Accept-Language
            Authorization Cookie Expect From Host If-Match If-Modified-Since
            If-None-Match If-Range If-Unmodified-Since Max-Forwards
            Proxy-Authorization Range Referer TE User-Agent

            Accept-Ranges Age ETag Location Proxy-Authenticate Retry-After
            Server Set-Cookie Vary WWW-Authenticate

            Allow Content-Encoding Content-Language Content-Length
            Content-Location Content-MD5 Content-Range Content-Type
            Expires Last-Modified
        >;
}

class HTTP::Headers:ver<0.3.0>:auth<github:zostay> { ... }

#| Role for defining all header objects
role HTTP::Header {
    has @.values is rw; #= The values stored by a header

    my @dow = <Mon Tue Wed Thu Fri Sat Sun>;
    my @moy = <Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec>;

    #| Convert objects stored into appropriately formatted strings
    method prepared-values(HTTP::Header:D: --> Seq) {
        @!values.map(-> $value is copy {
            given $value {
                when Instant {
                    $value = DateTime.new($value);
                    proceed;
                }
                when DateTime {
                    $value .= utc;
                    $value = sprintf "%s, %02d %s %04d %02d:%02d:%02d GMT",
                        @dow[.day-of-week - 1],
                        .day, @moy[.month - 1], .year,
                        .hour, .minute, .second;
                }
                when Duration {
                    $value .= Str;
                }
            }

            $value;
        });
    }

    #| Treat the values of this header as a single value
    method value(HTTP::Header:D: --> Str) is rw {
        my $self = self;
        return-rw Proxy.new(
            FETCH => method ()     { $self.prepared-values.join(', ') },
            STORE => method ($new) { ~($self.values = $new) },
        );
    }

    #| Retrieve the primary value out of the header value
    method primary(HTTP::Header:D: --> Str) is rw {
        my $self = self;
        return-rw Proxy.new(
            FETCH => method () {
                try {
                    if $self.values.elems > 0 {
                        $self.prepared-values[0].comb(/ <-[ ; ]>+ /)[0].trim
                    }
                    else {
                        Str
                    }
                }
            },
            STORE => method ($new) {
                my $value = @($self.prepared-values)[0];
                my @items = try { $value.comb(/ <-[ ; ]>+ /, 2) };
                @items[0] = $new.trim;
                @!values[0] = @items.join('; ');
                $new.trim;
            },
        );
    }

    #| Retrieve all the parameters associated with this header value
    method params(HTTP::Header:D: --> Hash:D) {
        my %result;
        my @pairs = try { self.prepared-values».comb(/ <-[ ; ]>+ /)».grep(/'='/).flat };
        for @pairs -> $pair {
            my ($key, $value) = $pair.split('=', 2);
            %result{$key.trim.lc} = $value.trim;
        }
        %result;
    }

    #| Set a header value on the string
    method set-param(HTTP::Header:D: Str:D $name, $new-value) {
        my $found = False;
        @!values = do for @(self.prepared-values) -> $prep-value {
            my @pairs = try { $prep-value.comb(/ <-[ ; ]>+ /) };
            my @result-pairs = gather for @pairs {
                when !$found && /'='/ { # only change the first
                    my ($key, $value) = .split('=', 2);
                    if ($key.trim.lc eq $name.trim.lc) {
                        $found++;
                        with $new-value {
                            take "{$key.trim}={$new-value.trim}"
                        }
                    }
                    else {
                        take $_
                    }
                }
                default { take $_ }
            };

            @result-pairs.push: "{$name.trim}={$new-value.trim}"
                unless $found;

            @result-pairs.join('; ');
        }
    }

    #| Read/write a parameter set within a value
    method param(HTTP::Header:D: Str:D $name) is rw {
        my $self = self;
        return-rw Proxy.new(
            FETCH => method ()     { $self.params{$name} },
            STORE => method ($new) { $self.set-param($name, $new) },
        );
    }

    #| Read the individual values as an array lookup
    method AT-POS(HTTP::Header:D: Int:D $index) { @!values[$index] }

    # TODO Why can't I make this a stub ... ?
    #method name { } #= The name of the header

    method key(HTTP::Header:D: --> Str:D) { self.name.lc } #= The header lookup key

    method push(HTTP::Header:D: *@values) { @!values.append: @values } #= Push values into the header
    method unshift(HTTP::Header:D: *@values) { @!values.append: @values } #= Unshift values into the header
    method shift(HTTP::Header:D: --> Any) { @!values.shift } #= Shift values off the header
    method pop(HTTP::Header:D: --> Any) { @!values.pop } #= Pop values off the header

    #| Set the given values only if the header has none already
    method init(HTTP::Header:D: *@values) {
        unless @!values {
            @!values = @values;
        }
    }

    #| Remove all values from this header
    method remove() { @!values = () }

    #| Output the header in Name: Value form for each value
    method as-string(HTTP::Header:D: Str:D :$eol = "\n" --> Str:D) {
        join $eol, do for self.prepared-values -> $value {
            "{self.name.Str}: $value";
        }
    }

    multi method gist(HTTP::Header:D: --> Str:D) { self.as-string }

    multi method Bool(HTTP::Header:D: --> Bool:D) { ?@!values } #= True if this header has values
    multi method Str(HTTP::Header:D: --> Str:D)  { self.value } #= Same as calling .value
    multi method Int(HTTP::Header:D: --> Int)  { self.value.Int } #= Treat the whole value as an Int
    multi method Numeric(HTTP::Header:D: --> Numeric) { self.value.Numeric } #= Treat the whole value as Numeric
    multi method list(HTTP::Header:D: --> List:D) { self.prepared-values.list } #= Same as calling .prepared-values
}

multi infix:<+> (HTTP::Header:D $h, Numeric:D() $v) {
    $h + $v;
}

#| A standard header definition
class HTTP::Header::Standard does HTTP::Header {
    has HTTP::Header::Standard::Name $.name;

    method clone {
        my HTTP::Header::Standard $obj .= new(:$!name);
        $obj.values = @.values;
        $obj;
    }
}

#| A Content-Type header definition
role HTTP::Header::Standard::Content-Type {
    method is-text { ?(self.primary ~~ /^ "text/" /) } #= True if the Content-Type is text/*
    method is-html { self.primary eq 'text/html' || self.is-xhtml } #= True if Content-Type is text/html or .is-xhtml
    method is-xhtml { #= True if Content-Type is xhtml
        ?(self.primary ~~ any(<
            application/xhtml+xml
            application/vnd.wap.xhtml+xml
        >));
    }
    method is-xml { #= True if Content-Type is xml
        ?(self.primary ~~ any(<
            text/xml
            application/xml
        >, /"+xml"/));
    }

    #| Read or write the charset parameter
    method charset is rw { return-rw self.param('charset') }
}

#| A custom header definition
class HTTP::Header::Custom does HTTP::Header {
    has Str $.name;

    method clone {
        my HTTP::Header::Custom $obj .= new(:$!name);
        $obj.values = @.values;
        $obj;
    }
}

#! A group of headers
class HTTP::Headers {
    has HTTP::Header %!headers; #= Internal header storage... no touchy
    has Bool $.quiet = False; #= Silence all warnings

    method internal-headers() { %!headers }

    #| Initialze headers with a list of pairs
    multi method new(@headers, Bool :$quiet = False) {
        my $self = self.bless(:$quiet);
        $self.headers(@headers) if @headers;
        $self;
    }

    #| Initialize headers with an array
    multi method new(%headers, Bool :$quiet = False) {
        my $self = self.bless(:$quiet);
        $self.headers(%headers) if %headers;
        $self;
    }

    #| Initialize headers empty or with a slurpy list of pairs or a slurpy hash
    multi method new(Bool :$quiet = False, *@headers, *%headers) {
        my $self = self.bless(:$quiet);
        $self.headers(%headers) if %headers;
        $self.headers(@headers) if @headers;
        $self;
    }

    #| Set multiple headers from a list of pairs
    multi method headers(@headers) {
        my $seen = SetHash.new;
        for flat @headers».kv -> $k, $v {
            if $seen ∋ $k {
                self.header($k).push: $v;
            }
            else {
                self.header($k) = $v;
                $seen{$k}++;
            }
        }
    }

    #| Set multiple headers from a hash
    multi method headers(%headers) {
        for flat %headers.kv -> $k, $v {
            self.header($k) = $v;
        }
    }

    #| Set multiple headers from a slurpy list of pairs or slurpy hash
    multi method headers(*@headers, *%headers) {
        my $seen = SetHash.new;
        for flat @headers».kv, %headers.kv -> $k, $v {
            if $seen ∋ $k {
                self.header($k).push: $v;
            }
            else {
                self.header($k) = $v;
                $seen{$k}++;
            }
        }
    }

    #| Helper for building header objects
    method build-header($name, *@values) returns HTTP::Header {
        my $std-name = $name;
        if $name ~~ Str {
            $std-name = $name.trans('_' => ' ', '-' => ' ').wordcase.trans(' ' => '-');
        }

        with ::("HTTP::Header::$std-name") -> $std {
            my $h = HTTP::Header::Standard.new(:name($std), :@values);
            if $std ~~ HTTP::Header::Standard::Name::Content-Type {
                $h but HTTP::Header::Standard::Content-Type;
            }
            else {
                $h
            }
        }

        else {
            HTTP::Header::Custom.new(:name($std-name), :@values);
        }
    }

    method AT-KEY($key)             { self.header($key) } #= use $headers{*} to fetch headers
    method ASSIGN-KEY($key, $value) { self.header($key) = $value } #= use $headers{*} to set headers
    method DELETE-KEY($key)         { self.remove-header($key) } #= use $headers{*} :delete to remove headers
    method EXISTS-KEY($key)         { ?self.header($key) } #= use $headers{*} :exists to test for the existance of a header

    #| Returns the number of headers set
    method elems { self.vacuum; %!headers.elems }

    #| Returns the headers as a sorted list
    method list { self.sorted-headers }

    #| Performs a safe deep clone of the headers
    method clone {
        my HTTP::Headers $obj .= new;
        for %!headers.kv -> $k, $v {
            $obj.internal-headers{$k} = $v.clone;
        }
        $obj;
    }

    #| Helper for use by .header()
    method header-proxy($name) is rw {
        my $tmp = self.build-header($name);
        my $h = %!headers{$tmp.key} //= $tmp;
        return-rw Proxy.new(
            FETCH => method ()      { $h },
            STORE => method (*@new) { $h.values = @new }
        );
    }

    #| Read or write a standard header
    multi method header(HTTP::Header::Standard::Name $name) is rw returns HTTP::Header {
        return-rw self.header-proxy($name);
    }

    #| Read or write a custom header
    multi method header(Str $name, :$quiet = False) is rw returns HTTP::Header {
        warn qq{Calling .header($name) is preferred to .header("$name") for standard HTTP headers.}
            if !$!quiet && !$quiet && ::("HTTP::Header::$name").defined;

        return-rw self.header-proxy($name);
    }

    #| Remove a header
    multi method remove-header($name) {
        my $tmp = self.build-header($name);
        %!headers{$tmp.key} :delete;
    }

    method remove-headers(*@names) {
        DEPRECATED('remove-header',|<0.2 1.0>);
        self.remove-header(|@names);
    }

    #| Remove more than one header
    multi method remove-header(*@names) {
        do for @names -> $name {
            my $tmp = self.build-header($name);
            %!headers{$tmp.key} :delete;
        }
    }

    #| Remove all the entity and Content-* headers
    method remove-content-headers {
        self.remove-header( %!headers.keys.grep(/^ content "-"/), <
            Allow Content-Encoding Content-Language Content-Length
            Content-Location Content-MD5 Content-Range Content-Type
            Expires Last-Modified
        >);
    }

    #| Remove all headers
    method clear { %!headers = () }

    #| Clean up header objects that have no values
    method vacuum {
        for %!headers.kv -> $k, $v {
            %!headers{$k} :delete if !$v;
        }
    }

    #| Return the headers as a sorted list
    method sorted-headers(HTTP::Headers:D: --> Seq) {
        self.vacuum;

        %!headers.values.sort(-> $a, $b {
            given $a.name {
                when HTTP::Header::Standard::Name {
                    given $b.name {
                        when HTTP::Header::Standard::Name { $a.name cmp $b.name }
                        default { Order::Less }
                    }
                }
                default {
                    given $b.name {
                        when HTTP::Header::Standard::Name { Order::More }
                        default { $a.name leg $b.name }
                    }
                }
            }
        })
    }

    method for(&code) is DEPRECATED("'map'") {
        # DEPRECATED WITHIN RAKUDO!!!
        self.sorted-headers.for: &code;
    }

    method map(&code) {
        self.sorted-headers.map: &code;
    }

    #| Iterate over the headers in sorted order
    method flatmap(&code) is DEPRECATED("'map' with 'flat'") {
        self.sorted-headers.map: &code;
    }

    #| Output the headers as a string in sorted order
    method as-string(Str :$eol = "\n") {
        self.vacuum;

        my $string = join $eol, self.sorted-headers.map: -> $header {
            $header.as-string(:$eol);
        };

        $string ~= $eol if $string;
        $string;
    }

    #! Same as as-string
    multi method Str(Str :$eol = "\n") { self.as-string(:$eol) }

    #| Return the headers as a list of Pairs for use with PSGI
    method for-PSGI is DEPRECATED("'for-P6WAPI'") {
        self.for-P6WAPI;
    }

    method for-P6SGI is DEPRECATED("'for-P6WAPI'") {
        self.for-P6WAPI;
    }

    method for-P6WAPI(HTTP::Headers:D: --> List:D) {
        self.sorted-headers.map(-> $h {
            do for $h.prepared-values -> $v {
                ~$h.name => ~$v
            }
        }).flat.list
    }

    method Cache-Control       is rw { return-rw self.header(HTTP::Header::Standard::Name::Cache-Control) }
    method Connection          is rw { return-rw self.header(HTTP::Header::Standard::Name::Connection) }
    method Date                is rw { return-rw self.header(HTTP::Header::Standard::Name::Date) }
    method Pragma              is rw { return-rw self.header(HTTP::Header::Standard::Name::Pragma) }
    method Trailer             is rw { return-rw self.header(HTTP::Header::Standard::Name::Trailer) }
    method Transfer-Encoding   is rw { return-rw self.header(HTTP::Header::Standard::Name::Transfer-Encoding) }
    method Upgrade             is rw { return-rw self.header(HTTP::Header::Standard::Name::Upgrade) }
    method Via                 is rw { return-rw self.header(HTTP::Header::Standard::Name::Via) }
    method Warning             is rw { return-rw self.header(HTTP::Header::Standard::Name::Warning) }

    method Accept              is rw { return-rw self.header(HTTP::Header::Standard::Name::Accept) }
    method Accept-Charset      is rw { return-rw self.header(HTTP::Header::Standard::Name::Accept-Charset) }
    method Accept-Encoding     is rw { return-rw self.header(HTTP::Header::Standard::Name::Accept-Encoding) }
    method Accept-Language     is rw { return-rw self.header(HTTP::Header::Standard::Name::Accept-Language) }
    method Authorization       is rw { return-rw self.header(HTTP::Header::Standard::Name::Authorization) }
    method Cookie              is rw { return-rw self.header(HTTP::Header::Standard::Name::Cookie) }
    method Expect              is rw { return-rw self.header(HTTP::Header::Standard::Name::Expect) }
    method From                is rw { return-rw self.header(HTTP::Header::Standard::Name::From) }
    method Host                is rw { return-rw self.header(HTTP::Header::Standard::Name::Host) }
    method If-Match            is rw { return-rw self.header(HTTP::Header::Standard::Name::If-Match) }
    method If-Modified-Since   is rw { return-rw self.header(HTTP::Header::Standard::Name::If-Modified-Since) }
    method If-None-Match       is rw { return-rw self.header(HTTP::Header::Standard::Name::If-None-Match) }
    method If-Range            is rw { return-rw self.header(HTTP::Header::Standard::Name::If-Range) }
    method If-Unmodified-Since is rw { return-rw self.header(HTTP::Header::Standard::Name::If-Unmodified-Since) }
    method Max-Forwards        is rw { return-rw self.header(HTTP::Header::Standard::Name::Max-Forwards) }
    method Proxy-Authorization is rw { return-rw self.header(HTTP::Header::Standard::Name::Proxy-Authorization) }
    method Range               is rw { return-rw self.header(HTTP::Header::Standard::Name::Range) }
    method Referer             is rw { return-rw self.header(HTTP::Header::Standard::Name::Referer) }
    method TE                  is rw { return-rw self.header(HTTP::Header::Standard::Name::TE) }
    method User-Agent          is rw { return-rw self.header(HTTP::Header::Standard::Name::User-Agent) }

    method Accept-Ranges       is rw { return-rw self.header(HTTP::Header::Standard::Name::Accept-Ranges) }
    method Age                 is rw { return-rw self.header(HTTP::Header::Standard::Name::Age) }
    method ETag                is rw { return-rw self.header(HTTP::Header::Standard::Name::ETag) }
    method Location            is rw { return-rw self.header(HTTP::Header::Standard::Name::Location) }
    method Proxy-Authenticate  is rw { return-rw self.header(HTTP::Header::Standard::Name::Proxy-Authenticate) }
    method Retry-After         is rw { return-rw self.header(HTTP::Header::Standard::Name::Retry-After) }
    method Server              is rw { return-rw self.header(HTTP::Header::Standard::Name::Server) }
    method Set-Cookie          is rw { return-rw self.header(HTTP::Header::Standard::Name::Set-Cookie) }
    method Vary                is rw { return-rw self.header(HTTP::Header::Standard::Name::Vary) }
    method WWW-Authenticate    is rw { return-rw self.header(HTTP::Header::Standard::Name::WWW-Authenticate) }

    method Allow               is rw { return-rw self.header(HTTP::Header::Standard::Name::Allow) }
    method Content-Encoding    is rw { return-rw self.header(HTTP::Header::Standard::Name::Content-Encoding) }
    method Content-Language    is rw { return-rw self.header(HTTP::Header::Standard::Name::Content-Language) }
    method Content-Length      is rw { return-rw self.header(HTTP::Header::Standard::Name::Content-Length) }
    method Content-Location    is rw { return-rw self.header(HTTP::Header::Standard::Name::Content-Location) }
    method Content-MD5         is rw { return-rw self.header(HTTP::Header::Standard::Name::Content-MD5) }
    method Content-Range       is rw { return-rw self.header(HTTP::Header::Standard::Name::Content-Range) }
    method Content-Type        is rw { return-rw self.header(HTTP::Header::Standard::Name::Content-Type) }
    method Expires             is rw { return-rw self.header(HTTP::Header::Standard::Name::Expires) }
    method Last-Modified       is rw { return-rw self.header(HTTP::Header::Standard::Name::Last-Modified) }
}
