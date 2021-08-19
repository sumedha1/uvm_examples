
module test;
  
class producer extends uvm_component;
  `uvm_component_utils(producer)
  
  uvm_blocking_put_port#(int) pport;
  
  function new(string name, uvm_component parent = null);
    super.new(name,parent);
    pport = new("pport", this);
  endfunction 
  
  task run_phase(uvm_phase phase);
    int t;
    repeat (10) begin
      t = $random%100;
      `uvm_info("PRODUCER", $sformatf("Sending item = %d", t), UVM_MEDIUM);
      pport.put(t);
      #10ns;
    end 
  endtask
  
  /*virtual task get(output int t);
    t = $random%100;
    `uvm_info("PRODUCER", $sformatf("Sending item = %d", t), UVM_MEDIUM);
  endtask*/ 
endclass

class consumer extends uvm_component;
  `uvm_component_utils(consumer)
  
  uvm_blocking_get_port#(int) gport;
  
  function new(string name, uvm_component parent = null);
    super.new(name,parent);
    gport = new("gport", this);
  endfunction 
  
  /*virtual task put(int t);
    `uvm_info("CONSUMER", $sformatf("Recieved item = %d", t), UVM_MEDIUM);
  endtask*/
  
  task run_phase(uvm_phase phase);
    int t;
    repeat (10) begin
      gport.get(t);
      `uvm_info("CONSUMER", $sformatf("Recieved item = %d", t), UVM_MEDIUM);
      #10ns;
    end 
  endtask
  
endclass 
  
class env extends uvm_env;
  `uvm_component_utils(env)
  producer p;
  consumer c; 
  uvm_tlm_fifo#(int) fifo;
  
  function new(string name="env", uvm_component parent = null);
    super.new(name, parent);
    p = new("p",this);
    c = new("c", this);
    fifo = new("fifo", this);
  endfunction 
  
  function void connect_phase(uvm_phase phase);
    p.pport.connect(fifo.put_export);
    c.gport.connect(fifo.get_export);
  endfunction 
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #1000ns;
    phase.drop_objection(this);
  endtask 
endclass
  
  env e;
  
  initial begin 
    e = new();
    
    run_test();
  end 

endmodule 
