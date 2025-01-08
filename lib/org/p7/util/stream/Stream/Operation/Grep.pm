
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

class Stream::Operation::Grep :isa(Stream::Operation::Node) {
    field $source    :param;
    field $predicate :param;

    field $next :reader;

    method has_next {
        return false unless $source->has_next;
        $next = $source->next;
        until ($predicate->test($next)) {
            return false unless $source->has_next;
            $next = $source->next;
        }
        return true;
    }
}
