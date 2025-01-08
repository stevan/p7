
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

class Stream::Operation::ForEach :isa(Stream::Operation::Terminal) {
    field $source   :param;
    field $consumer :param;

    method apply {
        while ($source->has_next) {
            $consumer->accept($source->next);
        }
        return;
    }
}
