
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logging ];

package Stream::Collectors {

    sub ToList { Stream::Collectors::Accumulator->new }

    sub JoinWith($, $sep='') {
        Stream::Functional::Accumulator->new(
            finisher => sub (@acc) { join $sep, @acc }
        )
    }

}

class Stream::Collectors::Accumulator {
    field $finisher :param = undef;
    field @acc;

    method accept ($arg) { LOG $self if DEBUG; push @acc => $arg; return; }

    method result { LOG $self if DEBUG; $finisher ? $finisher->( @acc ) : @acc }
}
