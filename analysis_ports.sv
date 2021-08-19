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
  
  uvm_analysis_imp#(int, sub1) iport;
  
  function new(string name="sub1", uvm_component parent=null);
    super.new(name,parent);
    iport = new("iport", this);
  endfunction 
  
  function void write(int t);
    `uvm_info("SUB1", $sformatf("Recieved t=%d",t), UVM_MEDIUM);
  endfunction
 
  
endclass 
  
class sub2 extends uvm_component;
  `uvm_component_utils(sub2)
  uvm_analysis_imp#(int, sub2) iport;
  
  function new(string name="sub2", uvm_component parent=null);
    super.new(name,parent);
    iport = new("iport", this);
  endfunction
  
  function void write(int t);
    `uvm_info("SUB2", $sformatf("Recieved t=%d",t/10), UVM_MEDIUM);
  endfunction
 
  
  
endclass 
  
class env extends uvm_env;
  `uvm_component_utils(env)
  producer p;
  sub1 s1; 
  sub2 s2;
  //uvm_tlm_fifo#(int) fifo;
  
  function new(string name="env", uvm_component parent = null);
    super.new(name, parent);
    p = new("p",this);
    s1 = new("s1", this);
    s2=new("s2",this);
    //fifo = new("fifo", this);
  endfunction 
  
  function void connect_phase(uvm_phase phase);
    p.port.connect(s1.iport);
    p.port.connect(s2.iport);
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
