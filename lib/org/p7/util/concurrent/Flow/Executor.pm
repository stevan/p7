
use v5.40;
use experimental qw[ class try ];

use module qw[ org::p7::util::concurrent ];

use org::p7::core::util qw[ Logging ];

class Flow::Executor {
    field $next :param :reader = undef;

    field @callbacks;

    method set_next ($n) {
        return $next = undef unless defined $n;

        # Check if setting this would create a cycle
        my $current = $n;
        my %seen;
        my $self_addr = refaddr($self);

        while ($current) {
            my $addr = refaddr($current);
            if ($addr == $self_addr) {
                die "Circular executor chain detected: setting next would create a cycle\n";
            }
            last if $seen{$addr}++;  # Stop if we hit an existing cycle (not involving $self)
            $current = $current->next;
        }

        $next = $n;
    }

    method remaining { scalar @callbacks }
    method is_done   { (scalar @callbacks == 0) ? 1 : 0 }

    method next_tick ($f) {
        LOG $self, { f => $f } if DEBUG;
        push @callbacks => $f
    }

    method tick {
        return $next unless @callbacks;
        TICK $self if DEBUG;
        LOG $self, '... running callbacks', { callbacks => scalar @callbacks } if DEBUG;
        my @to_run = @callbacks;
        @callbacks = ();
        while (my $f = shift @to_run) {
            LOG $self, ">>> calling f", { f => $f } if DEBUG;
            try {
                $f->();
            }
            catch ($e) {
                # Preserve remaining callbacks on exception
                unshift @callbacks, @to_run;
                LOG $self, "!!! exception in callback", { error => $e, remaining => scalar @callbacks } if DEBUG;
                die $e;  # Re-throw
            }
            LOG $self, "<<< called f", { f => $f } if DEBUG;
        }
        return $next;
    }

    method find_next_undone {
        my $current = $self;
        my %seen;

        while ($current) {
            return $current if $current->remaining > 0;

            my $addr = refaddr($current);
            return undef if $seen{$addr}++;  # Detect cycle

            $current = $current->next;
        }
        return undef;
    }

    method run {
        LOG $self if DEBUG;
        my $t = $self;
        my %seen;

        while (blessed $t && $t isa Flow::Executor) {
            LOG $self, "... calling tick", { t => $t } if DEBUG;

            # Detect cycles: if we've seen this executor multiple times and it's done, break
            my $addr = refaddr($t);
            if ($seen{$addr}++ > 1 && $t->is_done) {
                LOG $self, "... detected cycle with no work, terminating" if DEBUG;
                last;
            }

            $t = $t->tick;
            if (!$t) {
                LOG $self, "... looking for something to do" if DEBUG;
                %seen = ();  # Reset cycle detection when traversing chain
                $t = $self->find_next_undone;
            }
        }
        LOG $self, "... finished run", { callbacks => scalar @callbacks } if DEBUG;
        return;
    }

    method shutdown {
        LOG $self, '... shutting down' if DEBUG;
        $self->diag;
        LOG $self, '... THE END' if DEBUG;
    }

    method collect_all {
        my @all;
        my $current = $self;
        my %seen;

        while ($current) {
            my $addr = refaddr($current);
            last if $seen{$addr}++;  # Detect cycle

            push @all => $current;
            $current = $current->next;
        }

        return @all;
    }

    method diag {
        my @all = $self->collect_all;
        foreach my $exe (@all) {
            TICK $exe if DEBUG;
        }
        # TODO: do something here ...
    }

    method to_string {
        sprintf 'Executor[%d]' => refaddr $self;
    }
}
