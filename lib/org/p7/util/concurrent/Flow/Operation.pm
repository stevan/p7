
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::concurrent ];

use org::p7::core::util qw[ Logger ];

use Flow::Subscription;

class Flow::Operation {
    field $executor   :reader;
    field $downstream :reader;
    field $upstream   :reader;

    field @buffer;

    ADJUST {
        $executor = Flow::Executor->new;
    }

    method apply ($e) { ... }

    method submit ($value) {
        LOG $self, { value => $value } if DEBUG;
        push @buffer => $value;
        if ($downstream) {
            LOG $self, "... has downstream", { downstream => $downstream } if DEBUG;
            while (@buffer && $downstream) {
                LOG $self, "... has buffer", { buffer => scalar @buffer } if DEBUG;
                my $next = shift @buffer;
                LOG $self, "... offering", { e => $next } if DEBUG;
                $executor->next_tick(sub {
                    $downstream->offer( $next )
                });
            }
        }
    }

    method subscribe ($subscriber) {
        LOG $self, { downstream => $subscriber } if DEBUG;
        $downstream = Flow::Subscription->new(
            publisher  => $self,
            subscriber => $subscriber,
            executor   => $executor,
        );

        $executor->next_tick(sub {
            $subscriber->on_subscribe( $downstream );
        });
    }

    method unsubscribe ($downstream) {
        LOG $self, { downstream => $downstream } if DEBUG;
        $upstream->cancel;
        $upstream = undef;
    }

    method on_subscribe ($s) {
        LOG $self, { upstream => $s } if DEBUG;
        $upstream = $s;
        $upstream->executor->set_next( $executor );
        $upstream->request(1);
    }

    method on_unsubscribe {
        LOG $self if DEBUG;
        $executor->next_tick(sub {
            $downstream->on_unsubscribe;
        });
    }

    method on_next ($e) {
        LOG $self, { e => $e } if DEBUG;
        $upstream->request(1);
        $executor->next_tick(sub {
            $self->apply( $e );
        });
    }

    method on_completed {
        LOG $self if DEBUG;
        $executor->next_tick(sub {
            $downstream->on_completed;
        });
    }

    method on_error ($e) {
        LOG $self, { error => $e } if DEBUG;
        $executor->next_tick(sub {
            $downstream->on_error;
        });
    }

    method to_string {
        sprintf '%s[%d]' => (split '::' => __CLASS__)[-1], refaddr $self
    }
}

