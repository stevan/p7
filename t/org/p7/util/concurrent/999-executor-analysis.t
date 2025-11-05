#!perl
# Analysis tests for Flow::Executor to identify potential issues

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use org::p7::util::concurrent qw[ Flow::Executor ];

# Test 1: Can we create a circular reference?
subtest 'circular reference - two executors' => sub {
    my $exe2 = Flow::Executor->new;
    my $exe1 = Flow::Executor->new( next => $exe2 );
    $exe2->set_next($exe1);  # Create cycle: exe1 -> exe2 -> exe1

    ok(1, '... circular reference created');

    # What happens if we try to run with no callbacks?
    # This should terminate, but will it?

    # Let's add a safety counter
    my $tick_count = 0;
    my $max_ticks = 10;

    # Manual tick loop with limit
    my $t = $exe1;
    while (blessed $t && $t isa Flow::Executor && $tick_count < $max_ticks) {
        $tick_count++;
        $t = $t->tick;
        if (!$t) {
            # Try to find work
            $t = $exe1->find_next_undone;
        }
    }

    cmp_ok($tick_count, '>=', $max_ticks,
        '... circular reference causes infinite loop (hit limit)');
};

# Test 2: What happens with find_next_undone in a circular chain?
subtest 'find_next_undone with circular chain' => sub {
    my $exe2 = Flow::Executor->new;
    my $exe1 = Flow::Executor->new( next => $exe2 );
    $exe2->set_next($exe1);  # Create cycle

    # Try to find undone with no callbacks - will this terminate?
    my $found;
    eval {
        local $SIG{ALRM} = sub { die "timeout\n" };
        alarm(2);  # 2 second timeout
        $found = $exe1->find_next_undone;
        alarm(0);
    };

    if ($@ eq "timeout\n") {
        pass('... find_next_undone infinite loops on circular chain with no work');
    } else {
        fail('... expected timeout but got: ' . ($@ || 'no error'));
    }
};

# Test 3: collect_all with circular reference
subtest 'collect_all with circular chain' => sub {
    my $exe2 = Flow::Executor->new;
    my $exe1 = Flow::Executor->new( next => $exe2 );
    $exe2->set_next($exe1);  # Create cycle

    my @collected;
    eval {
        local $SIG{ALRM} = sub { die "timeout\n" };
        alarm(2);
        @collected = $exe1->collect_all;
        alarm(0);
    };

    if ($@ eq "timeout\n") {
        pass('... collect_all infinite loops on circular chain');
    } else {
        fail('... expected timeout but got: ' . ($@ || 'no error'));
    }
};

# Test 4: What if a callback dies?
subtest 'exception in callback' => sub {
    my $exe = Flow::Executor->new;
    my @executed;

    $exe->next_tick(sub { push @executed => 1 });
    $exe->next_tick(sub { die "callback error" });
    $exe->next_tick(sub { push @executed => 3 });

    eval { $exe->tick };

    ok($@, '... exception propagated');
    like($@, qr/callback error/, '... correct exception message');
    eq_or_diff(\@executed, [1],
        '... only callbacks before exception were executed');
    cmp_ok($exe->remaining, '==', 0,
        '... remaining callbacks were lost');
};

# Test 5: Long chain without cycle - stack depth
subtest 'long chain without cycle' => sub {
    my $last = Flow::Executor->new;
    my $first = $last;

    # Create a chain of 1000 executors
    for (1..1000) {
        $first = Flow::Executor->new(next => $first);
    }

    eval {
        my $found = $first->find_next_undone;
    };

    ok(!$@, '... long chain does not cause stack overflow')
        or diag("Error: $@");
};

# Test 6: Callbacks that infinitely add more callbacks
subtest 'infinite callback generation' => sub {
    my $exe = Flow::Executor->new;
    my $count = 0;
    my $max = 10;

    $exe->next_tick(sub {
        $count++;
        $exe->next_tick(sub { }) if $count < $max;
    });

    # Run just a few ticks
    for (1..15) {
        last if $exe->is_done;
        $exe->tick;
    }

    cmp_ok($count, '==', $max,
        '... callbacks can add more callbacks, runs until done');
};

# Test 7: Memory - do completed callbacks get freed?
subtest 'callback memory cleanup' => sub {
    my $exe = Flow::Executor->new;

    my $large_data = 'x' x 1000;
    $exe->next_tick(sub { length($large_data) });

    cmp_ok($exe->remaining, '==', 1, '... callback queued');

    $exe->tick;

    cmp_ok($exe->remaining, '==', 0, '... callback removed after execution');
    # The callback and its closure should now be freed
    # (though we can't easily test this without Devel::Peek)
};

# Test 8: Circular reference between callback and executor
subtest 'circular reference in closure' => sub {
    my $exe = Flow::Executor->new;

    # Create circular reference: callback captures $exe, $exe holds callback
    $exe->next_tick(sub {
        $exe->next_tick(sub { });  # Closure captures $exe
    });

    cmp_ok($exe->remaining, '==', 1, '... initial callback queued');
    $exe->tick;
    cmp_ok($exe->remaining, '==', 1, '... next callback queued');
    $exe->tick;
    cmp_ok($exe->remaining, '==', 0, '... all callbacks processed');

    # Circular ref exists but gets cleaned up when callbacks execute
    ok(1, '... circular references in closures are temporary');
};

done_testing;
