#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use org::p7::util::concurrent qw[ Flow::Publisher Flow::Subscriber ];
use org::p7::util::function   qw[ Consumer ];
use org::p7::core::util       qw[ Logger ];

my @seen;

DIV('build') if DEBUG;
my $publisher  = Flow::Publisher->new;
my $subscriber = Flow::Subscriber->new(
    request_size => 1,
    consumer => Consumer->new( f => sub ($e) {
        push @seen => $e;
        $publisher->submit( $e + 1 ) unless $e >= 10;
    })
);
$publisher->subscribe($subscriber);

DIV('submit') if DEBUG;
$publisher->submit( 1 );

DIV('start') if DEBUG;
$publisher->start;
DIV('close') if DEBUG;
$publisher->close;
DIV('done') if DEBUG;

eq_or_diff(\@seen, [1 .. 10], '... got the expected seen');

done_testing;




