#! /usr/bin/ruby

require 'test/unit'
require "vasputils.rb"
require 'vasputils/outcar.rb'

class TC_Outcar < Test::Unit::TestCase
    $tolerance = 10**(-10)

    def setup
        @o01        = VaspUtils::Outcar.load_file( "test/outcar/01-13-FIN.OUTCAR" )
        @o01int = VaspUtils::Outcar.load_file( "test/outcar/01-03-INT.OUTCAR" )
        @o02        = VaspUtils::Outcar.load_file( "test/outcar/02-05-FIN.OUTCAR" )
        @o03        = VaspUtils::Outcar.load_file( "test/outcar/03-05-FIN.OUTCAR" )
        @o04        = VaspUtils::Outcar.load_file( "test/outcar/10-01-FIN.OUTCAR" )
    end

    def test_self_load_file
        assert_raise(Errno::ENOENT){VaspUtils::Outcar.load_file( "" )}
    end

    #def test_nsw
    # assert_equal(100, @o01.nsw )
    # assert_equal(100, @o01int.nsw )
    # assert_equal(  2, @o02.nsw )
    # assert_equal(100, @o03.nsw )
    #end

    def test_normal_ended?
        assert_equal(true , @o01     [:normal_ended])
        assert_equal(false, @o01int[:normal_ended])
        assert_equal(true , @o02     [:normal_ended])
        assert_equal(true , @o03     [:normal_ended])
        assert_equal(true , @o04     [:normal_ended])
    end

    def test_ionic_steps
        assert_equal( 1, @o01       [:ionic_steps])
        assert_equal( 1, @o01int[:ionic_steps])
        assert_equal( 2, @o02       [:ionic_steps])
        assert_equal( 3, @o03       [:ionic_steps])
        assert_equal(10, @o04       [:ionic_steps])
    end

    def test_electronic_steps
        assert_equal(13, @o01       [:electronic_steps])
        assert_equal( 3, @o01int[:electronic_steps])
        assert_equal(18, @o02       [:electronic_steps])
        assert_equal(23, @o03       [:electronic_steps])
        assert_equal(30, @o04       [:electronic_steps])
    end

    def test_totens
        assert_in_delta(    64.17161363, @o01int[:totens][ 0], $tolerance )
        assert_in_delta( -11.78292768, @o01int[:totens][ 1], $tolerance )
        assert_in_delta( -19.56675908, @o01int[:totens][ 2], $tolerance )

        assert_in_delta(    64.17161363, @o01       [:totens][ 0], $tolerance)
        assert_in_delta( -11.78292768, @o01     [:totens][ 1], $tolerance)
        assert_in_delta( -19.56675908, @o01     [:totens][ 2], $tolerance)
        assert_in_delta( -19.74290414, @o01     [:totens][ 3], $tolerance)
        assert_in_delta( -19.74509430, @o01     [:totens][ 4], $tolerance)
        assert_in_delta( -15.85257458, @o01     [:totens][ 5], $tolerance)
        assert_in_delta( -15.67846403, @o01     [:totens][ 6], $tolerance)
        assert_in_delta( -15.65919488, @o01     [:totens][ 7], $tolerance)
        assert_in_delta( -15.64209986, @o01     [:totens][ 8], $tolerance)
        assert_in_delta( -15.64268703, @o01     [:totens][ 9], $tolerance)
        assert_in_delta( -15.64251873, @o01     [:totens][10], $tolerance)
        assert_in_delta( -15.64251991, @o01     [:totens][11], $tolerance)
        assert_in_delta( -15.64251763, @o01     [:totens][12], $tolerance)
        assert_in_delta( -15.642518  , @o01     [:totens][13], $tolerance)

        assert_in_delta(    64.17161363, @o02       [:totens][ 0], $tolerance )
        assert_in_delta( -11.78292768, @o02     [:totens][ 1], $tolerance )
        assert_in_delta( -19.56675908, @o02     [:totens][ 2], $tolerance )
        assert_in_delta( -19.74290414, @o02     [:totens][ 3], $tolerance )
        assert_in_delta( -19.74509430, @o02     [:totens][ 4], $tolerance )
        assert_in_delta( -15.85257458, @o02     [:totens][ 5], $tolerance )
        assert_in_delta( -15.67846403, @o02     [:totens][ 6], $tolerance )
        assert_in_delta( -15.65919488, @o02     [:totens][ 7], $tolerance )
        assert_in_delta( -15.64209986, @o02     [:totens][ 8], $tolerance )
        assert_in_delta( -15.64268703, @o02     [:totens][ 9], $tolerance )
        assert_in_delta( -15.64251873, @o02     [:totens][10], $tolerance )
        assert_in_delta( -15.64251991, @o02     [:totens][11], $tolerance )
        assert_in_delta( -15.64251763, @o02     [:totens][12], $tolerance )
        assert_in_delta( -15.642518  , @o02     [:totens][13], $tolerance )
        assert_in_delta( -15.65990112, @o02     [:totens][14], $tolerance )
        assert_in_delta( -15.64955447, @o02     [:totens][15], $tolerance )
        assert_in_delta( -15.64799040, @o02     [:totens][16], $tolerance )
        assert_in_delta( -15.64765795, @o02     [:totens][17], $tolerance )
        assert_in_delta( -15.64765312, @o02     [:totens][18], $tolerance )
        assert_in_delta( -15.647653  , @o02     [:totens][19], $tolerance )

        assert_in_delta(    64.17161363, @o03       [:totens][ 0], $tolerance )
        assert_in_delta( -11.78292768, @o03     [:totens][ 1], $tolerance )
        assert_in_delta( -19.56675908, @o03     [:totens][ 2], $tolerance )
        assert_in_delta( -19.74290414, @o03     [:totens][ 3], $tolerance )
        assert_in_delta( -19.74509430, @o03     [:totens][ 4], $tolerance )
        assert_in_delta( -15.85257458, @o03     [:totens][ 5], $tolerance )
        assert_in_delta( -15.67846403, @o03     [:totens][ 6], $tolerance )
        assert_in_delta( -15.65919488, @o03     [:totens][ 7], $tolerance )
        assert_in_delta( -15.64209986, @o03     [:totens][ 8], $tolerance )
        assert_in_delta( -15.64268703, @o03     [:totens][ 9], $tolerance )
        assert_in_delta( -15.64251873, @o03     [:totens][10], $tolerance )
        assert_in_delta( -15.64251991, @o03     [:totens][11], $tolerance )
        assert_in_delta( -15.64251763, @o03     [:totens][12], $tolerance )
        assert_in_delta( -15.642518  , @o03     [:totens][13], $tolerance )
        assert_in_delta( -15.65990112, @o03     [:totens][14], $tolerance )
        assert_in_delta( -15.64955447, @o03     [:totens][15], $tolerance )
        assert_in_delta( -15.64799040, @o03     [:totens][16], $tolerance )
        assert_in_delta( -15.64765795, @o03     [:totens][17], $tolerance )
        assert_in_delta( -15.64765312, @o03     [:totens][18], $tolerance )
        assert_in_delta( -15.647653  , @o03     [:totens][19], $tolerance )
        assert_in_delta( -15.65100443, @o03     [:totens][20], $tolerance )
        assert_in_delta( -15.64889598, @o03     [:totens][21], $tolerance )
        assert_in_delta( -15.64857840, @o03     [:totens][22], $tolerance )
        assert_in_delta( -15.64849678, @o03     [:totens][23], $tolerance )
        assert_in_delta( -15.64849543, @o03     [:totens][24], $tolerance )
        assert_in_delta( -15.648495  , @o03     [:totens][25], $tolerance )

        #assert_in_delta( Iter1-Nsw0/OUTCAR:549:    free energy      TOTEN  =        -51450.70587600
        #assert_in_delta( Iter1-Nsw0/OUTCAR:585:    free energy      TOTEN  =        -52760.43385845
        #assert_in_delta( Iter1-Nsw0/OUTCAR:621:    free energy      TOTEN  =        -52974.33537688
        #assert_in_delta( Iter1-Nsw0/OUTCAR:657:    free energy      TOTEN  =        -53114.51699744
        #assert_in_delta( Iter1-Nsw0/OUTCAR:693:    free energy      TOTEN  =        -53178.90296722
        #assert_in_delta( Iter1-Nsw0/OUTCAR:729:    free energy      TOTEN  =        -53226.44533651
        #assert_in_delta( Iter1-Nsw0/OUTCAR:772:    free energy      TOTEN  =        -53233.03344036
        #assert_in_delta( Iter1-Nsw0/OUTCAR:821:    free energy      TOTEN  =        -53232.27944261
        #assert_in_delta( Iter1-Nsw0/OUTCAR:870:    free energy      TOTEN  =        -53232.72830304
        #assert_in_delta( Iter1-Nsw0/OUTCAR:919:    free energy      TOTEN  =        -53232.71484487
        #assert_in_delta( Iter1-Nsw0/OUTCAR:968:    free energy      TOTEN  =        -53232.70895409
        #assert_in_delta( Iter1-Nsw0/OUTCAR:1017:    free energy        TOTEN    =      -53232.70751179
        #assert_in_delta( Iter1-Nsw0/OUTCAR:1055:    free energy        TOTEN    =      -53232.70759898
        #assert_in_delta( Iter1-Nsw0/OUTCAR:1463:    free    energy     TOTEN    =      -53232.707599
    end

    #def test_volume
    #    assert_in_delta( 44.88, @o01       [:volumes][0], $tolerance )
    #    assert_in_delta( 44.88, @o01       [:volumes][1], $tolerance )
    #    assert_in_delta( 44.88, @o01int[:volumes][0], $tolerance )
    #    assert_in_delta( 44.88, @o02       [:volumes][0], $tolerance )
    #    assert_in_delta( 44.88, @o02       [:volumes][1], $tolerance )
    #    assert_in_delta( 44.16, @o02       [:volumes][2], $tolerance )
    #    assert_in_delta( 44.88, @o03       [:volumes][0], $tolerance )
    #    assert_in_delta( 44.88, @o03       [:volumes][1], $tolerance )
    #    assert_in_delta( 44.16, @o03       [:volumes][2], $tolerance )
    #    assert_in_delta( 43.84, @o03       [:volumes][3], $tolerance )

    #    #assert_in_delta( Iter1-Nsw0/OUTCAR:343:    volume of cell :           1258.66
    #    #assert_in_delta( Iter1-Nsw0/OUTCAR:1488:  volume of cell :         1258.66

    #end

    def test_elapsed_time
        assert_equal(nil, @o01int[:elapsed_time])
        assert_in_delta(164.134, @o04[:elapsed_time], $tolerance )
    end

    #def test_irreducible_kpoints
    #    assert_equal(15, @o01[:irreducible_kpoints])
    #end

end
