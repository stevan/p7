
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::concurrent ];

use org::p7::core::util qw[ Logger ];

use Flow::Executor;
use Flow::Subscription;

class Flow::Publisher {
    field $executor     :reader;
    field $subscription :reader;

    field @buffer;

    ADJUST {
        $executor = Flow::Executor->new;
    }

    method drain_buffer {
        LOG $self if DEBUG;
        while (@buffer && $subscription) {
            LOG $self, "... has buffer", { buffer => scalar @buffer } if DEBUG;
            my $next = shift @buffer;
            LOG $self, "... offering", { e => $next } if DEBUG;
            $executor->next_tick(sub {
                $subscription->offer( $next )
            });
        }
    }

    method subscribe ($subscriber) {
        LOG $self, { subscriber => $subscriber } if DEBUG;
        $subscription = Flow::Subscription->new(
            publisher  => $self,
            subscriber => $subscriber,
            executor   => $executor,
        );

        LOG $self, '... sending on-subscribe' if DEBUG;
        $executor->next_tick(sub {
            $subscriber->on_subscribe( $subscription );
        });
    }

    method unsubscribe ($s) {
        LOG $self, { subscription => $s } if DEBUG;
        $subscription = undef;
        $executor->next_tick(sub {
            $s->on_unsubscribe;
        });
    }

    method submit ($value) {
        LOG $self, { value => $value } if DEBUG;
        push @buffer => $value;
        if ($subscription) {
            LOG $self, "... has subscription, offering", { subscription => $subscription } if DEBUG;
            $executor->next_tick(sub {
                $self->drain_buffer;
            });
        }
    }

    method start {
        LOG $self if DEBUG;
        $executor->run;
    }

    method close {
        LOG $self if DEBUG;
        if ($subscription) {
            LOG $self, "... has subscription", { subscription => $subscription } if DEBUG;
            if (@buffer) {
                LOG $self, "... dropping buffer", { buffer => scalar @buffer } if DEBUG;
                @buffer = ();
            }
            $executor->next_tick(sub {
                $subscription->on_completed;
            });

            $executor->run;
        }
        $executor->shutdown;
    }

    method to_string {
        sprintf 'Publisher[%d]' => refaddr $self;
    }
}
