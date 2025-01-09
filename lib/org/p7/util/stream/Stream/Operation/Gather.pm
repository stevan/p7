
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logger ];

class Stream::Operation::Gather :isa(Stream::Operation::Node) {
    field $source :param;
    field $init   :param;
    field $reduce :param;
    field $finish :param = undef;

    field $acc;
    field $next;

    ADJUST {
        $acc = $init->get;
        LOG $self, 'ADJUST', { source => $source, init => $init, reduce => $reduce, finish => $finish } if DEBUG;
    }

    method next { LOG $self if DEBUG; $finish ? $finish->apply($next) : $next }

    method has_next {
        LOG $self if DEBUG;
        $next = undef;

        my $seen = 0;
        while ($source->has_next) {
            $seen++;
            my $candidate = $source->next;
            #say "NEXT: $candidate";
            if ( $reduce->apply($candidate, $acc) ) {
                #say "IS DONE!";
                $next = $acc;
                $acc  = $init->get;
                return true;
            }
        }

        #say "!! Out of elements !! next(".($next // '~').") seen($seen)";
        if (!(defined $next) && $seen != 0) {
            #say "Found accumulated results! seen($seen) acc(".(join ', ' => @$acc).")";
            $next = $acc;
            return true;
        }

        #say "Okay, all done!";
        return false;
    }
}
