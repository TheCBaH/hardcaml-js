(rule
 (copy ../hardcaml/src/always.ml always.ml))

(rule
 (copy ../hardcaml/src/always.mli always.mli))

(rule
 (copy ../hardcaml/src/architecture.ml architecture.ml))

(rule
 (copy ../hardcaml/src/architecture.mli architecture.mli))

(rule
 (copy ../hardcaml/src/assertion_manager.ml assertion_manager.ml))

(rule
 (copy ../hardcaml/src/assertion_manager.mli assertion_manager.mli))

(rule
 (copy ../hardcaml/src/assertions.ml assertions.ml))

(rule
 (copy ../hardcaml/src/assertions.mli assertions.mli))

(rule
 (copy ../hardcaml/src/async_fifo.ml async_fifo.ml))

(rule
 (copy ../hardcaml/src/async_fifo.mli async_fifo.mli))

(rule
 (targets bits.ml)
 (deps ../hardcaml/src/bits.ml patches/bits.ml.patch)
 (action
  (with-stdout-to
   bits.ml
   (run patch -s -o - ../hardcaml/src/bits.ml patches/bits.ml.patch))))

(rule
 (copy ../hardcaml/src/bits.mli bits.mli))

(rule
 (copy ../hardcaml/src/bits0.ml bits0.ml))

(rule
 (copy ../hardcaml/src/bits0.mli bits0.mli))

(rule
 (copy ../hardcaml/src/bits_intf.ml bits_intf.ml))

(rule
 (copy ../hardcaml/src/bits_list.ml bits_list.ml))

(rule
 (copy ../hardcaml/src/bits_list.mli bits_list.mli))

(rule
 (targets bits_packed.ml)
 (deps ../hardcaml/src/bits_packed.ml patches/bits_packed.ml.patch)
 (action
  (with-stdout-to
   bits_packed.ml
   (run patch -s -o - ../hardcaml/src/bits_packed.ml patches/bits_packed.ml.patch))))

(rule
 (copy ../hardcaml/src/bits_packed.mli bits_packed.mli))

(rule
 (copy ../hardcaml/src/bits_stubs.c bits_stubs.c))

(rule
 (copy ../hardcaml/src/build_mode.ml build_mode.ml))

(rule
 (copy ../hardcaml/src/build_mode.mli build_mode.mli))

(rule
 (copy ../hardcaml/src/caller_id.ml caller_id.ml))

(rule
 (copy ../hardcaml/src/caller_id.mli caller_id.mli))

(rule
 (copy ../hardcaml/src/circuit.ml circuit.ml))

(rule
 (copy ../hardcaml/src/circuit.mli circuit.mli))

(rule
 (copy ../hardcaml/src/circuit_database.ml circuit_database.ml))

(rule
 (copy ../hardcaml/src/circuit_database.mli circuit_database.mli))

(rule
 (copy ../hardcaml/src/circuit_utilization.ml circuit_utilization.ml))

(rule
 (copy ../hardcaml/src/circuit_utilization.mli circuit_utilization.mli))

(rule
 (copy ../hardcaml/src/clocking.ml clocking.ml))

(rule
 (copy ../hardcaml/src/clocking.mli clocking.mli))

(rule
 (copy ../hardcaml/src/clocking_intf.ml clocking_intf.ml))

(rule
 (copy ../hardcaml/src/comb.ml comb.ml))

(rule
 (copy ../hardcaml/src/comb.mli comb.mli))

(rule
 (copy ../hardcaml/src/comb_intf.ml comb_intf.ml))

(rule
 (copy ../hardcaml/src/combinational_op.ml combinational_op.ml))

(rule
 (copy ../hardcaml/src/combinational_op.mli combinational_op.mli))

(rule
 (copy ../hardcaml/src/combinational_ops_database.ml combinational_ops_database.ml))

(rule
 (copy ../hardcaml/src/combinational_ops_database.mli combinational_ops_database.mli))

(rule
 (copy ../hardcaml/src/constant.ml constant.ml))

(rule
 (copy ../hardcaml/src/constant.mli constant.mli))

(rule
 (copy ../hardcaml/src/cross_product.ml cross_product.ml))

(rule
 (copy ../hardcaml/src/cross_product.mli cross_product.mli))

(rule
 (copy ../hardcaml/src/cross_product_intf.ml cross_product_intf.ml))

(rule
 (copy ../hardcaml/src/cyclesim.ml cyclesim.ml))

(rule
 (copy ../hardcaml/src/cyclesim.mli cyclesim.mli))

(rule
 (copy ../hardcaml/src/cyclesim0.ml cyclesim0.ml))

(rule
 (copy ../hardcaml/src/cyclesim0.mli cyclesim0.mli))

(rule
 (copy ../hardcaml/src/cyclesim0_intf.ml cyclesim0_intf.ml))

(rule
 (copy ../hardcaml/src/cyclesim2.ml cyclesim2.ml))

(rule
 (copy ../hardcaml/src/cyclesim2.mli cyclesim2.mli))

(rule
 (copy ../hardcaml/src/cyclesim2_ops.ml cyclesim2_ops.ml))

(rule
 (copy ../hardcaml/src/cyclesim2_ops.mli cyclesim2_ops.mli))

(rule
 (copy ../hardcaml/src/cyclesim_combine.ml cyclesim_combine.ml))

(rule
 (copy ../hardcaml/src/cyclesim_combine.mli cyclesim_combine.mli))

(rule
 (copy ../hardcaml/src/cyclesim_compile.ml cyclesim_compile.ml))

(rule
 (copy ../hardcaml/src/cyclesim_compile.mli cyclesim_compile.mli))

(rule
 (copy ../hardcaml/src/cyclesim_float_ops.ml cyclesim_float_ops.ml))

(rule
 (copy ../hardcaml/src/cyclesim_float_ops.mli cyclesim_float_ops.mli))

(rule
 (copy ../hardcaml/src/cyclesim_float_ops_intf.ml cyclesim_float_ops_intf.ml))

(rule
 (copy ../hardcaml/src/cyclesim_intf.ml cyclesim_intf.ml))

(rule
 (copy ../hardcaml/src/cyclesim_lookup.ml cyclesim_lookup.ml))

(rule
 (copy ../hardcaml/src/cyclesim_lookup.mli cyclesim_lookup.mli))

(rule
 (copy ../hardcaml/src/cyclesim_lookup_intf.ml cyclesim_lookup_intf.ml))

(rule
 (copy ../hardcaml/src/cyclesim_schedule.ml cyclesim_schedule.ml))

(rule
 (copy ../hardcaml/src/cyclesim_schedule.mli cyclesim_schedule.mli))

(rule
 (copy ../hardcaml/src/dedup.ml dedup.ml))

(rule
 (copy ../hardcaml/src/dedup.mli dedup.mli))

(rule
 (copy ../hardcaml/src/design_rule_checks.ml design_rule_checks.ml))

(rule
 (copy ../hardcaml/src/design_rule_checks.mli design_rule_checks.mli))

(rule
 (copy ../hardcaml/src/edge.ml edge.ml))

(rule
 (copy ../hardcaml/src/edge.mli edge.mli))

(rule
 (copy ../hardcaml/src/enum.ml enum.ml))

(rule
 (copy ../hardcaml/src/enum.mli enum.mli))

(rule
 (copy ../hardcaml/src/enum_intf.ml enum_intf.ml))

(rule
 (copy ../hardcaml/src/fifo.ml fifo.ml))

(rule
 (copy ../hardcaml/src/fifo.mli fifo.mli))

(rule
 (copy ../hardcaml/src/fifo_intf.ml fifo_intf.ml))

(rule
 (copy ../hardcaml/src/flags_vector.ml flags_vector.ml))

(rule
 (copy ../hardcaml/src/flags_vector.mli flags_vector.mli))

(rule
 (copy ../hardcaml/src/flags_vector_intf.ml flags_vector_intf.ml))

(rule
 (targets hardcaml.ml)
 (deps ../hardcaml/src/hardcaml.ml patches/hardcaml.ml.patch)
 (action
  (with-stdout-to
   hardcaml.ml
   (run patch -s -o - ../hardcaml/src/hardcaml.ml patches/hardcaml.ml.patch))))

(rule
 (copy ../hardcaml/src/hierarchy.ml hierarchy.ml))

(rule
 (copy ../hardcaml/src/hierarchy.mli hierarchy.mli))

(rule
 (copy ../hardcaml/src/instantiation.ml instantiation.ml))

(rule
 (copy ../hardcaml/src/instantiation.mli instantiation.mli))

(rule
 (copy ../hardcaml/src/interface.ml interface.ml))

(rule
 (copy ../hardcaml/src/interface.mli interface.mli))

(rule
 (copy ../hardcaml/src/interface_intf.ml interface_intf.ml))

(rule
 (copy ../hardcaml/src/level.ml level.ml))

(rule
 (copy ../hardcaml/src/level.mli level.mli))

(rule
 (copy ../hardcaml/src/logic.ml logic.ml))

(rule
 (copy ../hardcaml/src/logic.mli logic.mli))

(rule
 (copy ../hardcaml/src/logic_intf.ml logic_intf.ml))

(rule
 (copy ../hardcaml/src/mangler.ml mangler.ml))

(rule
 (copy ../hardcaml/src/mangler.mli mangler.mli))

(rule
 (copy ../hardcaml/src/pair.ml pair.ml))

(rule
 (copy ../hardcaml/src/pair.mli pair.mli))

(rule
 (copy ../hardcaml/src/pair_intf.ml pair_intf.ml))

(rule
 (copy ../hardcaml/src/parameter.ml parameter.ml))

(rule
 (copy ../hardcaml/src/parameter.mli parameter.mli))

(rule
 (copy ../hardcaml/src/parameter_name.ml parameter_name.ml))

(rule
 (copy ../hardcaml/src/parameter_name.mli parameter_name.mli))

(rule
 (copy ../hardcaml/src/ppx_hardcaml_runtime.ml ppx_hardcaml_runtime.ml))

(rule
 (copy ../hardcaml/src/ppx_hardcaml_runtime.mli ppx_hardcaml_runtime.mli))

(rule
 (copy ../hardcaml/src/property.ml property.ml))

(rule
 (copy ../hardcaml/src/property.mli property.mli))

(rule
 (copy ../hardcaml/src/property_manager.ml property_manager.ml))

(rule
 (copy ../hardcaml/src/property_manager.mli property_manager.mli))

(rule
 (copy ../hardcaml/src/ram.ml ram.ml))

(rule
 (copy ../hardcaml/src/ram.mli ram.mli))

(rule
 (copy ../hardcaml/src/read_port.ml read_port.ml))

(rule
 (copy ../hardcaml/src/read_port.mli read_port.mli))

(rule
 (copy ../hardcaml/src/reg_spec.ml reg_spec.ml))

(rule
 (copy ../hardcaml/src/reg_spec.mli reg_spec.mli))

(rule
 (copy ../hardcaml/src/reserved_words.ml reserved_words.ml))

(rule
 (copy ../hardcaml/src/reserved_words.mli reserved_words.mli))

(rule
 (copy ../hardcaml/src/rtl.ml rtl.ml))

(rule
 (copy ../hardcaml/src/rtl.mli rtl.mli))

(rule
 (copy ../hardcaml/src/rtl_ast.ml rtl_ast.ml))

(rule
 (copy ../hardcaml/src/rtl_ast.mli rtl_ast.mli))

(rule
 (copy ../hardcaml/src/rtl_attribute.ml rtl_attribute.ml))

(rule
 (copy ../hardcaml/src/rtl_attribute.mli rtl_attribute.mli))

(rule
 (copy ../hardcaml/src/rtl_deprecated.ml rtl_deprecated.ml))

(rule
 (copy ../hardcaml/src/rtl_deprecated.mli rtl_deprecated.mli))

(rule
 (copy ../hardcaml/src/rtl_intf.ml rtl_intf.ml))

(rule
 (copy ../hardcaml/src/rtl_name.ml rtl_name.ml))

(rule
 (copy ../hardcaml/src/rtl_name.mli rtl_name.mli))

(rule
 (copy ../hardcaml/src/rtl_name_intf.ml rtl_name_intf.ml))

(rule
 (copy ../hardcaml/src/rtl_verilog_of_ast.ml rtl_verilog_of_ast.ml))

(rule
 (copy ../hardcaml/src/rtl_verilog_of_ast.mli rtl_verilog_of_ast.mli))

(rule
 (copy ../hardcaml/src/rtl_vhdl_of_ast.ml rtl_vhdl_of_ast.ml))

(rule
 (copy ../hardcaml/src/rtl_vhdl_of_ast.mli rtl_vhdl_of_ast.mli))

(rule
 (copy ../hardcaml/src/scalar.ml scalar.ml))

(rule
 (copy ../hardcaml/src/scalar.mli scalar.mli))

(rule
 (copy ../hardcaml/src/scalar_intf.ml scalar_intf.ml))

(rule
 (copy ../hardcaml/src/scope.ml scope.ml))

(rule
 (copy ../hardcaml/src/scope.mli scope.mli))

(rule
 (copy ../hardcaml/src/side.ml side.ml))

(rule
 (copy ../hardcaml/src/side.mli side.mli))

(rule
 (copy ../hardcaml/src/signal.ml signal.ml))

(rule
 (copy ../hardcaml/src/signal.mli signal.mli))

(rule
 (copy ../hardcaml/src/signal__type.ml signal__type.ml))

(rule
 (copy ../hardcaml/src/signal__type.mli signal__type.mli))

(rule
 (copy ../hardcaml/src/signal__type_intf.ml signal__type_intf.ml))

(rule
 (copy ../hardcaml/src/signal_graph.ml signal_graph.ml))

(rule
 (copy ../hardcaml/src/signal_graph.mli signal_graph.mli))

(rule
 (copy ../hardcaml/src/signal_intf.ml signal_intf.ml))

(rule
 (copy ../hardcaml/src/signedness.ml signedness.ml))

(rule
 (copy ../hardcaml/src/signedness.mli signedness.mli))

(rule
 (copy ../hardcaml/src/structural.ml structural.ml))

(rule
 (copy ../hardcaml/src/structural.mli structural.mli))

(rule
 (copy ../hardcaml/src/structural_intf.ml structural_intf.ml))

(rule
 (copy ../hardcaml/src/topsort.ml topsort.ml))

(rule
 (copy ../hardcaml/src/topsort.mli topsort.mli))

(rule
 (copy ../hardcaml/src/types.ml types.ml))

(rule
 (copy ../hardcaml/src/types.mli types.mli))

(rule
 (copy ../hardcaml/src/value.ml value.ml))

(rule
 (copy ../hardcaml/src/value.mli value.mli))

(rule
 (copy ../hardcaml/src/value_intf.ml value_intf.ml))

(rule
 (copy ../hardcaml/src/vcd.ml vcd.ml))

(rule
 (copy ../hardcaml/src/vcd.mli vcd.mli))

(rule
 (copy ../hardcaml/src/wave_data.ml wave_data.ml))

(rule
 (copy ../hardcaml/src/wave_data.mli wave_data.mli))

(rule
 (copy ../hardcaml/src/wave_data_intf.ml wave_data_intf.ml))

(rule
 (copy ../hardcaml/src/wave_format.ml wave_format.ml))

(rule
 (copy ../hardcaml/src/wave_format.mli wave_format.mli))

(rule
 (copy ../hardcaml/src/with_valid.ml with_valid.ml))

(rule
 (copy ../hardcaml/src/with_valid.mli with_valid.mli))

(rule
 (copy ../hardcaml/src/with_valid_intf.ml with_valid_intf.ml))

(rule
 (copy ../hardcaml/src/write_port.ml write_port.ml))

(rule
 (copy ../hardcaml/src/write_port.mli write_port.mli))

(rule
 (copy ../hardcaml/src/zarith.ml zarith.ml))

