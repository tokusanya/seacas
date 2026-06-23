// Copyright(C) 1999-2020, 2022, 2025 National Technology & Engineering Solutions
// of Sandia, LLC (NTESS).  Under the terms of Contract DE-NA0003525 with
// NTESS, the U.S. Government retains certain rights in this software.
//
// See packages/seacas/LICENSE for details

#ifdef SEACAS_HAVE_MPI
#include "mpi.h"
#endif
#include "gtest/gtest.h"

#include "FileUtils.h"
#include "MeshFixture.h"

namespace {

  class NemSliceTester : public utest_util::MeshFixture
  {
  public:
    NemSliceTester() : utest_util::MeshFixture(3)
    {
      Ioss::Init::Initializer io;
      setup_empty_mesh();
    }

    ~NemSliceTester() {}

  protected:
 
  };


  TEST_F(NemSliceTester, emptyTest) {}

  TEST_F(NemSliceTester, beamOneDimSideIds)
  {
    std::string inputFile  = "dummy.g";
    std::string outputFile = utest_util::unique_filename("beamOneDimSideIds", "g");

    //std::string meshDesc = "textmesh:"
    //                      "0,1,HEX_8,1,2,3,4,5,6,7,8,block_1"
    //                       "|coordinates:   0,0,0, 1,0,0, 1,1,0, 0,1,0, 0,0,1, 1,0,1, 1,1,1, 0,1,1";

    std::string meshDesc = "textmesh:"
                           "0,1,BEAM_2,1,2,block_1\n"
                           "0,2,BEAM_2,2,3,block_1\n"
                           "|coordinates:   0,1,2\n"
                           "|dimension:   1";

    setup_mesh(meshDesc);

    Ioss::PropertyManager props;
    auto copy_opts = get_default_mesh_copy_options();
    write_region_to_file(get_mesh().get_region(), props, copy_opts, outputFile);

  }


} // namespace
