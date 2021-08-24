// Code your testbench here
// or browse Examples

`include "uvm_macros.svh"
import uvm_pkg::*;

interface serial_intf(input clk);
  logic data;
  
  clocking drv @(posedge clk);
    output data;
  endclocking 
  
  clocking mon @(posedge clk);
    input data;
  endclocking 
endinterface 


module top;
  import uvm_pkg::*;
  
  logic clk;
  
  serial_intf vif(.*);
  
  initial begin 
    clk <=0;
    forever #2ns clk <= ~clk;
  end 
 
  
  initial begin 
    uvm_config_db#(virtual serial_intf)::set(null, "*", "vif", vif);
    run_test("my_test");
  end 
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, top);
  end 
endmodule 


class seq_item extends uvm_sequence_item;
  rand bit[4:0] len;
  rand bit[31:0] data;
  
  `uvm_object_utils_begin(seq_item)
    `uvm_field_int(len,UVM_ALL_ON)
    `uvm_field_int(data,UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name = "seq_item");
    super.new(name);
  endfunction
  
  constraint my_c {
    len != 0; 
  }
endclass

class my_seq extends uvm_sequence#(seq_item);
  `uvm_object_utils(my_seq)
  function new(string name = "my_seq");
    super.new(name);
  endfunction
  
  task body();
    seq_item req;
    req = seq_item::type_id::create("req");
    
    start_item(req);
    
    req.randomize();
    `uvm_info("SEQ", $sformatf("sent req: len: %b data: %b", req.len, req.data), UVM_MEDIUM)
    finish_item(req);
    `uvm_info("SEQ", " Item Done", UVM_MEDIUM)
  endtask
  
endclass
  
class my_seqr extends uvm_sequencer#(seq_item);
  `uvm_component_utils(my_seqr)
  function new(string name = "my_seqr", uvm_component parent=null);
    super.new(name, parent);
  endfunction
endclass
  
class driver extends uvm_driver#(seq_item);
  `uvm_component_utils(driver)
  virtual serial_intf intf;
  
  function new(string name = "driver", uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual serial_intf)::get(this, "", "vif", intf))`uvm_fatal("DRIVER", "interface not found") 
  endfunction
  
  task run_phase(uvm_phase phase);
    seq_item req;
    
    forever begin
      
      drive_idle();
      seq_item_port.get_next_item(req);
      `uvm_info("DRV", "Got req", UVM_MEDIUM)
      drive_item(req);
      seq_item_port.item_done(req);
      
    end 
  endtask
  
  virtual task drive_item(seq_item req);
    for (int i=0; i<7+req.len; i++) begin
      @(posedge intf.clk); 
      if (i==0)intf.drv.data <= 0;
      else if(i== 6+req.len) intf.drv.data <= 1;
      else if (i>0 && i<6) intf.drv.data <= req.len[i-1];
      else if (i>=6 && i<6+req.len) intf.drv.data <= req.data[i-6];
    end 
  endtask
  
  virtual task drive_idle();
    @(posedge intf.clk);
    intf.drv.data <= 1;
  endtask
endclass 
    
    
class monitor extends uvm_monitor#(seq_item);
  `uvm_component_utils(monitor)
  virtual serial_intf intf;
  
  function new(string name = "monitor", uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual serial_intf)::get(this, "", "vif", intf))`uvm_fatal("MONITOR", "interface not found") 
  endfunction
  
  task run_phase(uvm_phase phase);
    seq_item req;
    
    forever begin
      
      drive_idle();
      seq_item_port.get_next_item(req);
      `uvm_info("DRV", "Got req", UVM_MEDIUM)
      drive_item(req);
      seq_item_port.item_done(req);
      
    end 
  endtask
  
  virtual task drive_item(seq_item req);
    for (int i=0; i<7+req.len; i++) begin
      @(posedge intf.clk); 
      if (i==0)intf.drv.data <= 0;
      else if(i== 6+req.len) intf.drv.data <= 1;
      else if (i>0 && i<6) intf.drv.data <= req.len[i-1];
      else if (i>=6 && i<6+req.len) intf.drv.data <= req.data[i-6];
    end 
  endtask
  
  virtual task drive_idle();
    @(posedge intf.clk);
    intf.drv.data <= 1;
  endtask
endclass 
    
class my_test extends uvm_test;
  `uvm_component_utils(my_test)
  driver d;
  my_seq s;
  my_seqr sqr;
  
  function new(string name = "my_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    d = driver::type_id::create("d", this);
    sqr = my_seqr::type_id::create("sqr", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    d.seq_item_port.connect(sqr.seq_item_export);
  endfunction
  
   task run_phase(uvm_phase phase);
     s=my_seq::type_id::create("s");
     phase.raise_objection(this);
     s.start(sqr);
     `uvm_info("TEST", "Test running", UVM_MEDIUM)
     phase.drop_objection(this);
   endtask
  
endclass
