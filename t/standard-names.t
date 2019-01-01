use v6;
use Test;

use HTTP::Headers :standard-names;

my $headers = HTTP::Headers.new(
        Accept => 1,
    Accept-Charset => 2,
    Accept-Encoding => 3,
    Accept-Language => 4,
    Accept-Ranges => 5,
    Age => 6,
    Allow => 7,
    Authorization => 8,
    Cache-Control => 9,
    Connection => 10,
    Content-Encoding => 11,
    Content-Language => 12,
    Content-Length => 13,
    Content-Location => 14,
    Content-MD5 => 15,
    Content-Range => 16,
    Content-Type => 17,
    Cookie => 18,
    Date => 19,
    ETag => 20,
    Expect => 21,
    Expires => 22,
    From => 23,
    Host => 24,
    If-Match => 25,
    If-Modified-Since => 26,
    If-None-Match => 27,
    If-Range => 28,
    If-Unmodified-Since => 29,
    Last-Modified => 30,
    Location => 31,
    Max-Forwards => 32,
    Pragma => 33,
    Proxy-Authenticate => 34,
    Proxy-Authorization => 35,
    Range => 36,
    Referer => 37,
    Retry-After => 38,
    Server => 39,
    Set-Cookie => 40,
    TE => 41,
    Trailer => 42,
    Transfer-Encoding => 43,
    Upgrade => 44,
    User-Agent => 45,
    Vary => 46,
    Via => 47,
    WWW-Authenticate => 48,
    Warning => 49,
):quiet;

is $headers.Accept, 1, q[standard header method works: Accept];
is $headers.Accept-Charset, 2, q[standard header method works: Accept-Charset];
is $headers.Accept-Encoding, 3, q[standard header method works: Accept-Encoding];
is $headers.Accept-Language, 4, q[standard header method works: Accept-Language];
is $headers.Accept-Ranges, 5, q[standard header method works: Accept-Ranges];
is $headers.Age, 6, q[standard header method works: Age];
is $headers.Allow, 7, q[standard header method works: Allow];
is $headers.Authorization, 8, q[standard header method works: Authorization];
is $headers.Cache-Control, 9, q[standard header method works: Cache-Control];
is $headers.Connection, 10, q[standard header method works: Connection];
is $headers.Content-Encoding, 11, q[standard header method works: Content-Encoding];
is $headers.Content-Language, 12, q[standard header method works: Content-Language];
is $headers.Content-Length, 13, q[standard header method works: Content-Length];
is $headers.Content-Location, 14, q[standard header method works: Content-Location];
is $headers.Content-MD5, 15, q[standard header method works: Content-MD5];
is $headers.Content-Range, 16, q[standard header method works: Content-Range];
is $headers.Content-Type, 17, q[standard header method works: Content-Type];
is $headers.Cookie, 18, q[standard header method works: Cookie];
is $headers.Date, 19, q[standard header method works: Date];
is $headers.ETag, 20, q[standard header method works: ETag];
is $headers.Expect, 21, q[standard header method works: Expect];
is $headers.Expires, 22, q[standard header method works: Expires];
is $headers.From, 23, q[standard header method works: From];
is $headers.Host, 24, q[standard header method works: Host];
is $headers.If-Match, 25, q[standard header method works: If-Match];
is $headers.If-Modified-Since, 26, q[standard header method works: If-Modified-Since];
is $headers.If-None-Match, 27, q[standard header method works: If-None-Match];
is $headers.If-Range, 28, q[standard header method works: If-Range];
is $headers.If-Unmodified-Since, 29, q[standard header method works: If-Unmodified-Since];
is $headers.Last-Modified, 30, q[standard header method works: Last-Modified];
is $headers.Location, 31, q[standard header method works: Location];
is $headers.Max-Forwards, 32, q[standard header method works: Max-Forwards];
is $headers.Pragma, 33, q[standard header method works: Pragma];
is $headers.Proxy-Authenticate, 34, q[standard header method works: Proxy-Authenticate];
is $headers.Proxy-Authorization, 35, q[standard header method works: Proxy-Authorization];
is $headers.Range, 36, q[standard header method works: Range];
is $headers.Referer, 37, q[standard header method works: Referer];
is $headers.Retry-After, 38, q[standard header method works: Retry-After];
is $headers.Server, 39, q[standard header method works: Server];
is $headers.Set-Cookie, 40, q[standard header method works: Set-Cookie];
is $headers.TE, 41, q[standard header method works: TE];
is $headers.Trailer, 42, q[standard header method works: Trailer];
is $headers.Transfer-Encoding, 43, q[standard header method works: Transfer-Encoding];
is $headers.Upgrade, 44, q[standard header method works: Upgrade];
is $headers.User-Agent, 45, q[standard header method works: User-Agent];
is $headers.Vary, 46, q[standard header method works: Vary];
is $headers.Via, 47, q[standard header method works: Via];
is $headers.WWW-Authenticate, 48, q[standard header method works: WWW-Authenticate];
is $headers.Warning, 49, q[standard header method works: Warning];

is $headers.header(Accept), 1, q[standard header enum works: Accept];
is $headers.header(Accept-Charset), 2, q[standard header enum works: Accept-Charset];
is $headers.header(Accept-Encoding), 3, q[standard header enum works: Accept-Encoding];
is $headers.header(Accept-Language), 4, q[standard header enum works: Accept-Language];
is $headers.header(Accept-Ranges), 5, q[standard header enum works: Accept-Ranges];
is $headers.header(Age), 6, q[standard header enum works: Age];
is $headers.header(Allow), 7, q[standard header enum works: Allow];
is $headers.header(Authorization), 8, q[standard header enum works: Authorization];
is $headers.header(Cache-Control), 9, q[standard header enum works: Cache-Control];
is $headers.header(Connection), 10, q[standard header enum works: Connection];
is $headers.header(Content-Encoding), 11, q[standard header enum works: Content-Encoding];
is $headers.header(Content-Language), 12, q[standard header enum works: Content-Language];
is $headers.header(Content-Length), 13, q[standard header enum works: Content-Length];
is $headers.header(Content-Location), 14, q[standard header enum works: Content-Location];
is $headers.header(Content-MD5), 15, q[standard header enum works: Content-MD5];
is $headers.header(Content-Range), 16, q[standard header enum works: Content-Range];
is $headers.header(Content-Type), 17, q[standard header enum works: Content-Type];
is $headers.header(Cookie), 18, q[standard header enum works: Cookie];
is $headers.header(Date), 19, q[standard header enum works: Date];
is $headers.header(ETag), 20, q[standard header enum works: ETag];
is $headers.header(Expect), 21, q[standard header enum works: Expect];
is $headers.header(Expires), 22, q[standard header enum works: Expires];
is $headers.header(From), 23, q[standard header enum works: From];
is $headers.header(Host), 24, q[standard header enum works: Host];
is $headers.header(If-Match), 25, q[standard header enum works: If-Match];
is $headers.header(If-Modified-Since), 26, q[standard header enum works: If-Modified-Since];
is $headers.header(If-None-Match), 27, q[standard header enum works: If-None-Match];
is $headers.header(If-Range), 28, q[standard header enum works: If-Range];
is $headers.header(If-Unmodified-Since), 29, q[standard header enum works: If-Unmodified-Since];
is $headers.header(Last-Modified), 30, q[standard header enum works: Last-Modified];
is $headers.header(Location), 31, q[standard header enum works: Location];
is $headers.header(Max-Forwards), 32, q[standard header enum works: Max-Forwards];
is $headers.header(Pragma), 33, q[standard header enum works: Pragma];
is $headers.header(Proxy-Authenticate), 34, q[standard header enum works: Proxy-Authenticate];
is $headers.header(Proxy-Authorization), 35, q[standard header enum works: Proxy-Authorization];
is $headers.header(Range), 36, q[standard header enum works: Range];
is $headers.header(Referer), 37, q[standard header enum works: Referer];
is $headers.header(Retry-After), 38, q[standard header enum works: Retry-After];
is $headers.header(Server), 39, q[standard header enum works: Server];
is $headers.header(Set-Cookie), 40, q[standard header enum works: Set-Cookie];
is $headers.header(TE), 41, q[standard header enum works: TE];
is $headers.header(Trailer), 42, q[standard header enum works: Trailer];
is $headers.header(Transfer-Encoding), 43, q[standard header enum works: Transfer-Encoding];
is $headers.header(Upgrade), 44, q[standard header enum works: Upgrade];
is $headers.header(User-Agent), 45, q[standard header enum works: User-Agent];
is $headers.header(Vary), 46, q[standard header enum works: Vary];
is $headers.header(Via), 47, q[standard header enum works: Via];
is $headers.header(WWW-Authenticate), 48, q[standard header enum works: WWW-Authenticate];
is $headers.header(Warning), 49, q[standard header enum works: Warning];

done-testing;
