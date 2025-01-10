
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::core::compiler ];

use org::p7::core::util     qw[ Logging ];
use org::p7::util::function qw[ Predicate ];

package Decompiler::Tools::Events {
    sub InsideCallSite {
        return Predicate->new(
            f => sub ($op) {
                state $in_callsite = false;
                if ($op->name eq 'entersub') {
                    $in_callsite = true;
                    return true;
                }

                if ($in_callsite && ($op->name eq 'gv' || $op->name eq 'method_named')) {
                    $in_callsite = false;
                    return true;
                }

                return $in_callsite;
            }
        )
    }

    sub OnStatementChange {
        return Predicate->new(
            f => sub ($op) {
                state $curr_stmt;
                # keep assigning it until we get something
                if (not(defined $curr_stmt) && defined $op->statement) {
                    $curr_stmt = $op->statement;
                    return true;
                }
                # return false if we get nothing ...
                return false unless $curr_stmt;

                if ($curr_stmt->addr != $op->statement->addr) {
                    $curr_stmt = $op->statement;
                    return true;
                }

                return false;
            }
        )
    }
}
