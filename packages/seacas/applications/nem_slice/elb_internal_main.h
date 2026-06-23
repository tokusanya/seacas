/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/
/* Routine which reads in a EXODUS II mesh database and load balances the
 * mesh by either a nodal or element assignment.
 *----------------------------------------------------------------------------
 * Functions called:
 *      cmd_line_arg_parse()
 *      read_cmd_file()
 *      check_inp_specs()
 *      print_input()
 *      read_exo_weights()
 *      read_mesh_params()
 *      read_mesh()
 *      generate_gaph()
 *      generate_loadbal()
 *      write_vis()
 *      generate_maps()
 *      write_nemesis()
 *----------------------------------------------------------------------------
 * Variable Index:
 *      machine       - structure containing information about the machine
 *                      for which the load balance is to be generated.
 *      lb            - structure containing information about what type
 *                      of load balance is to be performed.
 *      problem       - structure containing information about the problem
 *                      type. Currently whether the problem is a nodal or
 *                      elemental based decomposition.
 *      solver        - structure containing various parameters for the
 *                      eigensolver used by Chaco.
 *      weight        - structure used to store parameters about how to
 *                      weight the resulting graph before it is fed into
 *                      Chaco.
 *      graph         - structure containing the graph of the problem.
 *      mesh          - structure containing a description of the FEM mesh.
 *      exoII_inp_file - name of the ExodusII file containing the problem
 *                       geometry.
 *      ascii_inp_file - name of the input command file.
 *      nemI_out_file  - name of the output NemesisI file.
 *
 *****************************************************************************/
#pragma once

template <typename INT> int internal_main(int argc, char *argv[], INT /* dummy */);