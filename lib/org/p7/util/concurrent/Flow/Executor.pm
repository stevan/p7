
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::concurrent ];

use org::p7::core::util qw[ Logging ];

class Flow::Executor {
    field $next :param :reader = undef;

    field @callbacks;

    method set_next ($n) { $next = $n }

    method remaining { scalar @callbacks }
    method is_done   { scalar @callbacks == 0 }

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
            $f->();
            LOG $self, "<<< called f", { f => $f } if DEBUG;
        }
        return $next;
    }

    method find_next_undone {
        return $self                   if @callbacks;
        return $next->find_next_undone if $next;
        return;
    }

    method run {
        LOG $self if DEBUG;
        my $t = $self;
        while (blessed $t && $t isa Flow::Executor) {
            LOG $self, "... calling tick", { t => $t } if DEBUG;
            $t = $t->tick;
            if (!$t) {
                LOG $self, "... looking for something to do" if DEBUG;
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

    method collect_all { ($self, $next ? $next->collect_all : ()) }

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
