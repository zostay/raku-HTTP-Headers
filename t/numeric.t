use v6;
use Test;

use HTTP::Headers :standard-names;

my @num-headers = Age;
my @int-headers = Content-Length;

my $headers = HTTP::Headers.new;

todo 'we want to type check Age header, but do not do so yet';
dies-ok { $headers.header(Age) = 'x' }, "cannot assign non-decimals to Age";
lives-ok { $headers.header(Age) = 12.4 }, "can assign decimal on Age";
lives-ok { $headers.header(Age) += 3.7 }, "can udpate decimal on Age";
is $headers.header(Age), 16.1, "decimal assignments worked as expected for Age";

todo 'we want to type check Content-Length headers, but do not do so yet';
dies-ok { $headers.header(Content-Length) = 'x' }, "cannot assign non-decimals to Content-Length";
lives-ok { $headers.header(Content-Length) = 12 }, "can assign decimal on Content-Length";
lives-ok { $headers.header(Content-Length) += 3 }, "can udpate decimal on Content-Length";
is $headers.header(Content-Length), 15, "decimal assignments worked as expected for Content-Length";

done-testing;
