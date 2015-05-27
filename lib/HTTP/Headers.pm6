use v6;

enum HTTP::Headers::Standard is export 
    # General, Request, Response, Entity Headers
    <
        Cache-Control Connection Date Pragma Trailer Transfer-Encoding
        Upgrade Via Warning

        Accept Accept-Charset Accept-Encoding Accept-Language
        Authorization Expect From Host If-Match If-Modified-Since
        If-None-Match If-Range If-Unmodified-Since Max-Forwards
        Proxy-Authorization Range Referer TE User-Agent

        Accept-Ranges Age ETag Location Proxy-Authenticate Retry-After
        Server Vary WWW-Authenticate

        Allow Content-Encoding Content-Language Content-Length
        Content-Location Content-MD5 Content-Range Content-Type
        Expires Last-Modified
    >;

class HTTP::Headers { ... }

role HTTP::Header {
    has @.values is rw;

    my @dow = <Mon Tue Wed Thu Fri Sat Sun>;
    my @moy = <Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec>;
    method prepared-values {
        do for @!values -> $value is copy {
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
        }
    }

    method value { self.prepared-values.join(', ') }

    method primary {
        try { self.prepared-values[0].comb(/ <-[ ; ]>+ /)[0].trim }
    }

    method params {
        my %result;
        my @pairs = try { self.prepared-values».comb(/ <-[ ; ]>+ /)».grep(/'='/) };
        for @pairs -> $pair {
            my ($key, $value) = $pair.split('=', 2);
            %result{$key.trim.lc} = $value.trim;
        }
        %result;
    }

    method AT-POS($index) { @!values[$index] }

    method name { }
    method key returns Str { self.name.lc }

    method push(*@values) { @!values.push: @values }
    method unshift(*@values) { @!values.push: @values }
    method shift() { @!values.shift }
    method pop() { @!values.pop }

    method init(*@values) {
        unless @!values {
            @!values = @values;
        }
    }
    
    method remove() { @!values = () }

    method as-string(Str :$eol = "\n") {
        my @values = self.prepared-values;
        my @lines = do for @values -> $value {
            "{self.name}: $value";
        }
        @lines.join($eol);
    }

    method Bool { ?@!values }
    method Str  { self.value }
    method list { @!values }
}

class HTTP::Header::Standard is HTTP::Header {
    has HTTP::Headers::Standard $.name;

    method clone {
        my HTTP::Header::Standard $obj .= new(:$!name);
        $obj.values = @.values;
        $obj;
    }
}

role HTTP::Header::Standard::Content-Type {
    method is-text { ?(self.primary ~~ /^ "text/" /) }
    method is-html { self.primary eq 'text/html' || self.is-xhtml }
    method is-xhtml { 
        ?(self.primary ~~ any(<
            application/xhtml+xml
            application/vnd.wap.xhtml+xml
        >));
    }
    method is-xml {
        ?(self.primary ~~ any(<
            text/xml
            application/xml
        >, /"+xml"/));
    }

    method charset {
        self.params<charset>
    }

}

class HTTP::Header::Custom is HTTP::Header {
    has Str $.name;

    submethod BUILD(:$!name) {
        $!name = $!name.trans('_' => ' ', '-' => ' ').wordcase.trans(' ' => '-');
    }

    method clone {
        my HTTP::Header::Custom $obj .= new(:$!name);
        $obj.values = @.values;
        $obj;
    }
}

class HTTP::Headers {
    has HTTP::Header %.headers;

    method build-header($name, *@values) returns HTTP::Header { 
        if my $std = HTTP::Headers::Standard($name) {
            my $h = HTTP::Header::Standard.new(:name($std), :@values);
            if $std ~~ HTTP::Headers::Standard::Content-Type {
                $h but HTTP::Header::Standard::Content-Type;
            }
            else {
                $h
            }
        }
        else {
            HTTP::Header::Custom.new(:$name, :@values);
        }
    }

    method AT-KEY($key)             { self.header($key) }
    method ASSIGN-KEY($key, $value) { self.header($key) = $value }
    method DELETE-KEY($key)         { self.remove-header($key) }
    method EXISTS-KEY($key)         { ?self.header($key) }

    method elems { self.vacuum; %!headers.elems }

    method list { self.sorted-headers }

    method clone {
        my HTTP::Headers $obj .= new;
        for %!headers.kv -> $k, $v {
            $obj.headers{$k} = $v.clone;
        }
        $obj;
    }

    method header-proxy($name) {
        my $tmp = self.build-header($name);
        my $h = %!headers{$tmp.key} //= $tmp;
        Proxy.new(
            FETCH => method ()      { $h },
            STORE => method (*@new) { $h.values = @new }
        );
    }

    multi method header(HTTP::Headers::Standard $name) is rw returns HTTP::Header {
        self.header-proxy($name);
    }

    multi method header(Str $name, :$quiet = False) is rw returns HTTP::Header {
        warn qq{Calling .header($name) is preferred to .header("$name") for standard HTTP headers.}
            if !$quiet && HTTP::Headers::Standard($name);

        self.header-proxy($name);
    }

    method remove-header($name) {
        my $tmp = self.build-header($name);
        %!headers{$tmp.key} :delete;
    }

    method remove-headers(*@names) {
        do for @names -> $name {
            my $tmp = self.build-header($name);
            %!headers{$tmp.key} :delete;
        }
    }

    method remove-content-headers {
        self.remove-headers( %!headers.keys.grep(/^ content "-"/), <
            Allow Content-Encoding Content-Language Content-Length
            Content-Location Content-MD5 Content-Range Content-Type
            Expires Last-Modified
        >);
    }

    method clear { %!headers = () }

    method vacuum {
        for %!headers.kv -> $k, $v {
            %!headers{$k} :delete if !$v;
        }
    }

    method sorted-headers {
        self.vacuum;

        %!headers.values.sort: -> $a, $b {
            given $a.name {
                when HTTP::Headers::Standard {
                    given $b.name {
                        when HTTP::Headers::Standard { $a.name cmp $b.name }
                        default { Order::Less }
                    }
                }
                default {
                    given $b.name {
                        when HTTP::Headers::Standard { Order::More }
                        default { $a.name leg $b.name }
                    }
                }
            }
        }
    }

    method for(&code) {
        self.sorted-headers.for: &code;
    }

    method as-string(Str :$eol = "\n") {
        self.vacuum;

        my $string = join $eol, self.for: -> $header {
            $header.as-string(:$eol);
        };

        $string ~= $eol if $string;
        $string;
    }

    method Str { self.as-string }

    method for-PSGI {
        self.for: -> $h { 
            do for $h.prepared-values -> $v {
                ~$h.name => ~$v
            }
        }
    }

    method Cache-Control       is rw { self.header(HTTP::Headers::Standard::Cache-Control) }
    method Connection          is rw { self.header(HTTP::Headers::Standard::Connection) }
    method Date                is rw { self.header(HTTP::Headers::Standard::Date) }
    method Pragma              is rw { self.header(HTTP::Headers::Standard::Pragma) }
    method Trailer             is rw { self.header(HTTP::Headers::Standard::Trailer) }
    method Transfer-Encoding   is rw { self.header(HTTP::Headers::Standard::Transfer-Encoding) }
    method Upgrade             is rw { self.header(HTTP::Headers::Standard::Upgrade) }
    method Via                 is rw { self.header(HTTP::Headers::Standard::Via) }
    method Warning             is rw { self.header(HTTP::Headers::Standard::Warning) }

    method Accept              is rw { self.header(HTTP::Headers::Standard::Accept) }
    method Accept-Charset      is rw { self.header(HTTP::Headers::Standard::Accept-Charset) }
    method Accept-Encoding     is rw { self.header(HTTP::Headers::Standard::Accept-Encoding) }
    method Accept-Langauge     is rw { self.header(HTTP::Headers::Standard::Accept-Language) }
    method Authorization       is rw { self.header(HTTP::Headers::Standard::Authorization) }
    method Expect              is rw { self.header(HTTP::Headers::Standard::Expect) }
    method From                is rw { self.header(HTTP::Headers::Standard::From) }
    method Host                is rw { self.header(HTTP::Headers::Standard::Host) }
    method If-Match            is rw { self.header(HTTP::Headers::Standard::If-Match) }
    method If-Modified-Since   is rw { self.header(HTTP::Headers::Standard::If-Modified-Since) }
    method If-None-Match       is rw { self.header(HTTP::Headers::Standard::If-None-Match) }
    method If-Range            is rw { self.header(HTTP::Headers::Standard::If-Range) }
    method If-Unmodified-Since is rw { self.header(HTTP::Headers::Standard::If-Unmodified-Since) }
    method Max-Forwards        is rw { self.header(HTTP::Headers::Standard::Max-Forwards) }
    method Proxy-Authorization is rw { self.header(HTTP::Headers::Standard::Proxy-Authorization) }
    method Range               is rw { self.header(HTTP::Headers::Standard::Range) }
    method Referer             is rw { self.header(HTTP::Headers::Standard::Referer) }
    method TE                  is rw { self.header(HTTP::Headers::Standard::TE) }
    method User-Agent          is rw { self.header(HTTP::Headers::Standard::User-Agent) }

    method Accept-Ranges       is rw { self.header(HTTP::Headers::Standard::Accept-Ranges) }
    method Age                 is rw { self.header(HTTP::Headers::Standard::Age) }
    method ETag                is rw { self.header(HTTP::Headers::Standard::ETag) }
    method Location            is rw { self.header(HTTP::Headers::Standard::Location) }
    method Proxy-Authenticate  is rw { self.header(HTTP::Headers::Standard::Proxy-Authenticate) }
    method Retry-After         is rw { self.header(HTTP::Headers::Standard::Retry-After) }
    method Server              is rw { self.header(HTTP::Headers::Standard::Server) }
    method Vary                is rw { self.header(HTTP::Headers::Standard::Vary) }
    method WWW-Authenticate    is rw { self.header(HTTP::Headers::Standard::WWW-Authenticate) }

    method Allow               is rw { self.header(HTTP::Headers::Standard::Allow) }
    method Content-Encoding    is rw { self.header(HTTP::Headers::Standard::Content-Encoding) }
    method Content-Language    is rw { self.header(HTTP::Headers::Standard::Content-Language) }
    method Content-Length      is rw { self.header(HTTP::Headers::Standard::Content-Length) }
    method Content-Location    is rw { self.header(HTTP::Headers::Standard::Content-Location) }
    method Content-MD5         is rw { self.header(HTTP::Headers::Standard::Content-MD5) }
    method Content-Range       is rw { self.header(HTTP::Headers::Standard::Content-Range) }
    method Content-Type        is rw { self.header(HTTP::Headers::Standard::Content-Type) }
    method Expires             is rw { self.header(HTTP::Headers::Standard::Expires) }
    method Last-Modified       is rw { self.header(HTTP::Headers::Standard::Last-Modified) }
}
