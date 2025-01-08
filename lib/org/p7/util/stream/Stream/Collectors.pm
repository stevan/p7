
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

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

    method accept ($arg) { push @acc => $arg; return; }

    method result { $finisher ? $finisher->( @acc ) : @acc }
}
