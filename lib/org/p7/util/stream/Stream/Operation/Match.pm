
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logging ];

class Stream::Operation::Match :isa(Stream::Operation::Terminal) {
    field $matcher  :param :reader;
    field $source   :param :reader;

    ADJUST {
        LOG $self, 'ADJUST', { source => $source, matcher => $matcher } if DEBUG;
    }

    method apply {
        LOG $self if DEBUG;
        my $current = $matcher;
        while ($source->has_next) {
            TICK $self if DEBUG;
            my $op = $source->next;

            if ($current->is_match($op)) {
                if ($current->has_next) {
                    $current = $current->next;
                }
                else {
                    return $current->match_found($op);
                }
            }
            else {
                last;
            }
        }
        return;
    }
}
