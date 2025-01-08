
use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use org::p7::io::stream qw[ IO::Stream::Files ];

open my $fh, '<', __FILE__;

my $s = IO::Stream::Files->bytes( $fh, size => 8 )->foreach(sub ($x) {
    ok(length($x) <= 8, '... nothing is longer than 8 characters')
});

done_testing;
