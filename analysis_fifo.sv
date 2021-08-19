module test;
  
class producer extends uvm_component;
  `uvm_component_utils(producer)
  
  uvm_analysis_port#(int) port;
  
  function new(string name, uvm_component parent = null);
    super.new(name,parent);
    port = new("port", this);
  endfunction 
  
  task run_phase(uvm_phase phase);
    int t;
    repeat (10) begin
      t = $random%100;
      `uvm_info("PRODUCER", $sformatf("Sending item = %d", t), UVM_MEDIUM);
      port.write(t);
      #10ns;
    end 
  endtask
  
 
endclass

class sub1 extends uvm_component;
  `uvm_component_utils(sub1)
  
  uvm_blocking_get_port#(int) gport;
  
  function new(string name="sub1", uvm_component parent=null);
    super.new(name,parent);
    gport = new("gport", this);
  endfunction 
  
  task run_phase(uvm_phase phase);
    int t;
    repeat(5) begin
      gport.get(t);
      `uvm_info("SUB1", $sformatf("Got item = %d", t), UVM_MEDIUM);
    end 
  endtask
  
endclass 
  
class sub2 extends uvm_component;
  `uvm_component_utils(sub2)
  
  uvm_blocking_get_port#(int) gport;
  
  function new(string name="sub2", uvm_component parent=null);
    super.new(name,parent);
    gport = new("gport", this);
  endfunction
  
  task run_phase(uvm_phase phase);
    int t;
    repeat(5) begin
      #100ns;
      gport.get(t);
      `uvm_info("SUB2", $sformatf("Got item = %d", t), UVM_MEDIUM);
    end 
  endtask
 
  
  
endclass 
  
class env extends uvm_env;
  `uvm_component_utils(env)
  producer p;
  sub1 s1; 
  sub2 s2;
  uvm_tlm_analysis_fifo#(int) fifo1;
  uvm_tlm_analysis_fifo#(int) fifo2;
  function new(string name="env", uvm_component parent = null);
    super.new(name, parent);
    p = new("p",this);
    s1 = new("s1", this);
    s2=new("s2",this);
    fifo1 = new("fifo1", this);
    fifo2 = new("fifo2", this);
  endfunction 
  
  function void connect_phase(uvm_phase phase);
    p.port.connect(fifo1.analysis_export);
    p.port.connect(fifo2.analysis_export);
    s1.gport.connect(fifo1.get_export);
    s2.gport.connect(fifo2.get_export);
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
