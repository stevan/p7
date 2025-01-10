
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::concurrent ];

use org::p7::core::util qw[ Logging ];

class Flow::Subscription {
    field $publisher  :param :reader;
    field $subscriber :param :reader;
    field $executor   :param :reader;

    field $requested = 0;
    field @buffer;

    method drain_buffer {
        LOG $self if DEBUG;
        while (@buffer && $requested) {
            LOG $self, { requested => $requested, buffer => scalar @buffer } if DEBUG;
            $requested--;
            my $next = shift @buffer;
            $executor->next_tick(sub {
                $self->on_next($next);
            });
        }
    }


    method request ($n) {
        LOG $self, { n => $n } if DEBUG;
        $requested += $n;
        if (@buffer) {
            $executor->next_tick(sub {
                $self->drain_buffer;
            });
        }
    }

    method cancel {
        LOG $self if DEBUG;
        $executor->next_tick(sub {
            $publisher->unsubscribe( $self );
        });
    }

    method offer ($e) {
        LOG $self, { e => $e } if DEBUG;
        push @buffer => $e;
        if ($requested) {
            LOG $self, "... has requested", { requested => $requested } if DEBUG;
            $executor->next_tick(sub {
                $self->drain_buffer;
            });
        }
    }

    method on_unsubscribe {
        LOG $self if DEBUG;
        $executor->next_tick(sub {
            $subscriber->on_unsubscribe;
        });
    }

    method on_next ($e) {
        LOG $self, { e => $e } if DEBUG;
        $executor->next_tick(sub {
            $subscriber->on_next( $e );
        });
    }

    method on_completed {
        LOG $self if DEBUG;
        $executor->next_tick(sub {
            $subscriber->on_completed;
        });
    }

    method on_error ($e) {
        LOG $self, { error => $e } if DEBUG;
        $executor->next_tick(sub {
            $subscriber->on_error( $e );
        });
    }

    method to_short {
        sprintf '%d@(%s,%s)' => refaddr $self,
        map { (split '::' => $_)[-1] } blessed $publisher, blessed $subscriber;
    }

    method to_string {
        sprintf 'Subscription[%d]<%s,%s>' => refaddr $self,
        map { (split '::' => $_)[-1] } blessed $publisher, blessed $subscriber;
    }
}
