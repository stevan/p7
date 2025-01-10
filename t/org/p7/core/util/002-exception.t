
use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use org::p7::core::util qw[ Exception ];

subtest '... simple exception' => sub {
    my $e = Exception->new( msg => "Hello" );
    isa_ok($e, 'Exception');

    is($e->msg, 'Hello', '... got the expected message');

    my @trace = $e->stack;
    foreach my $t (@trace) {
        isa_ok($t, 'Exception::StackFrame');
    }
};



subtest '... simple exception' => sub {
    my sub throwit { Exception->new( msg => "Hello" ) }

    my $e = throwit();
    isa_ok($e, 'Exception');

    is($e->msg, 'Hello', '... got the expected message');

    my @trace = $e->stack;

    is($trace[0]->subroutine, 'throwit', '... got the expected subroutine');

    foreach my $t (@trace) {
        isa_ok($t, 'Exception::StackFrame');
    }
};

done_testing;
