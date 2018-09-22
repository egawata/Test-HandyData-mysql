#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use Data::HandyGen::mysql;


main();
exit(0);


sub main {
    my $hd = Data::HandyGen::mysql->new();

    test_random($hd);
    test_fixval($hd);

    dies_ok { $hd->determine_value() } '(Invalid) no argument';
    dies_ok { $hd->determine_value(1) } '(Invalid) scalar';
    dies_ok { $hd->determine_value([1]) } '(Invalid) arrayref';
    lives_ok { $hd->determine_value({}) } '(Valid) empty hashref';

    done_testing;
}


sub test_random {
    my ($hd) = @_;

    subtest 'random' => sub {
        subtest 'one value' => sub {
            my $value;
            $value = $hd->determine_value({ random => [1] });
            is($value, 1);
            $value = $hd->determine_value({ random => [0] });
            is($value, 0);

            #  We allow undef.
            $value = $hd->determine_value({ random => [ undef ] });
            is($value, undef);
        };

        subtest 'array with many value' => sub {
            for ( 1..5 ) {
                my $value = $hd->determine_value({ random => [ 1, 2, 3 ] });
                ok( $value == 1 or $value == 2 or $value == 3);
            }
        };

        subtest 'regex' => sub {
            my $pattern = 'Z[0-9a-f]{16}\.jpg';
            my $value = $hd->determine_value({ random => qr/$pattern/ });
            like $value, qr/^$pattern$/;
        };

        subtest 'invalid' => sub {
            dies_ok { $hd->determine_value({ random => undef }) } '(Invalid) undef';
            dies_ok { $hd->determine_value({ random => [] }) } '(Invalid) empty arrayref';
            dies_ok { $hd->determine_value({ random => 1 }) } '(Invalid) scalar';
            dies_ok { $hd->determine_value({ random => { value => 1 }}) } '(Invalid) hashref';
        };
    };
}

sub test_fixval {
    my ($hd) = @_;

    my $value;
    $value = $hd->determine_value({fixval => 100});
    is($value, 100);
    $value = $hd->determine_value({fixval => undef});
    is($value, undef);

    dies_ok { $hd->determine_value({ fixval => [ 1 ] }) } '(Invalid) arrayref';
    dies_ok { $hd->determine_value({ fixval => { value => 1 } }) } '(Invalid) hashref';
}


