
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::core::compiler ];

use org::p7::core::util qw[ Logging ];

class Decompiler::Source::Optree :isa(Stream::Source) {
    field $cv :param :reader;

    field $started = false;
    field $stopped = false;

    field $next;
    field @stack;

    field $invisible_statement;
    field $current_statement;

    ADJUST {
        $invisible_statement = Decompiler::Context::InvisibleStatement->new( cv => $cv );
        $current_statement   = $invisible_statement;

        $next = $self->_wrap_in_context($cv->ROOT);
    }

    ## ---------------------------------------------------------------------------------------------
    ## Context methods
    ## ---------------------------------------------------------------------------------------------

    method _wrap_in_context ($op) {
        Decompiler::Context::Opcode->new(
            stack     => [ @stack ],
            statement => $current_statement,
            op        => $op
        )
    }

    method _wrap_statement ($op) {
        Decompiler::Context::Statement->new( op => $op )
    }

    ## ---------------------------------------------------------------------------------------------
    ## Source methods ...
    ## ---------------------------------------------------------------------------------------------

    method next { $next }

    method has_next {
        return false if not defined $next;

        say('-' x 40) if DEBUG;
        if (!$started) {
            $started = true;
            say "Not started yet, setting up $next" if DEBUG;
            return true;
        }

        my $candidate = $next->op;

        say "Processing $candidate" if DEBUG;
        if ($next->has_descendents) {
            say ".... $candidate has kids" if DEBUG;
            push @stack => $next;
            $candidate = $candidate->first;
            say ".... + $candidate is first kid" if DEBUG;
        }
        else {
            say ".... $candidate does not have kids" if DEBUG;
            my $sibling = $candidate->sibling;
            if ($$sibling) {
                say ".... $candidate has sibling" if DEBUG;
                $candidate = $sibling;
                say ".... + candidate is sibling" if DEBUG;
            }
            else {
                say ".... $candidate does not have any more siblings" if DEBUG;
                while (@stack) {
                    my $_next = pop @stack;
                    say "<< back to $_next ..." if DEBUG;
                    my $sibling = $_next->op->sibling;
                    if ($$sibling) {
                        $candidate = $sibling;
                        last;
                    }
                }

                unless (@stack) {
                    say "..... ** We ran out of stack, so we are back to root" if DEBUG;
                    $next    = undef;
                    $stopped = true;
                }
            }
        }

        say "!!!! next is: ".($next // '~') if DEBUG;
        return false unless $next;

        $current_statement = $self->_wrap_statement($candidate)
            if $candidate isa B::COP;

        $next = $self->_wrap_in_context($candidate);

        return true;
    }
}
