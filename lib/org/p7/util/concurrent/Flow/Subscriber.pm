
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::concurrent ];

use org::p7::core::util qw[ Logger ];

class Flow::Subscriber {
    field $request_size :param :reader = 1;
    field $consumer     :param :reader;

    field $subscription;
    field $count;

    method on_subscribe ($s) {
        LOG $self, { subscription => $s } if DEBUG;
        $subscription = $s;
        $count        = $request_size;
        $subscription->request( $request_size );
    }

    method on_unsubscribe {
        LOG $self if DEBUG;
        $subscription = undef;
    }

    method on_next ($e) {
        LOG $self, { e => $e, count => $count } if DEBUG;
        if (--$count <= 0) {
            LOG $self, "... refresh?", {
                count        => $count,
                size         => $request_size,
                subscription => $subscription
            } if DEBUG;
            $count = $request_size;
            $subscription->request( $request_size );
            LOG $self, "... refreshed!" if DEBUG;
        }
        LOG $self, "... consumer->apply", { e => $e } if DEBUG;
        $consumer->accept( $e );
    }

    method on_completed {
        LOG $self if DEBUG;
        $subscription->cancel if $subscription;
    }

    method on_error ($e) {
        LOG $self, { error => $e } if DEBUG;
        $subscription->cancel if $subscription;
    }

    method to_string {
        sprintf 'Subscriber[%d]' => refaddr $self;
    }
}
