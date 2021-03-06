/*
 * Copyright (C) 2017 Francisco Manuel Garcia Moreno
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
//-----------------------------------------------
// Grammar for PL GOTO
//-----------------------------------------------

header{
	package com.fgarmo.plgoto;
	import java.util.*;
	import antlr.*;
}

class Anasint extends Parser; 

options{
   	buildAST=true; 
   	k=2;  
}

tokens{ 
	PROGRAM;
	MACRO;
	BLOCK;
}

{
	public Map<String, AST[]> labels = new HashMap<String, AST[]>();
	ASTFactory factory = new ASTFactory();
	
	void registerLeftLabelledInst(String label, AST[] expression){
		if(!labels.containsKey(label)){
			labels.put(label, expression);
		}
		else{
			//System.out.println("Compilation Error: duplicated label "+label);
			throw new RuntimeException("Compilation Error: duplicated label "+label);	
		}	
	}
}

// The Program
program: order
	{#program = #(#[PROGRAM,"PROGRAM"], ##);}
;

order: (DEFMACRO ID_MACRO)=> (macro_def)*
 	| instructions_block
	;

macro_def: DEFMACRO! ID_MACRO instructions_block ENDMACRO!
	{#macro_def = #(#[MACRO,"MACRO"], ##);}
;

instructions_block: (LSB! ID_LABEL) => labelled_instruction
	| basic_instruction (instructions_block)?
;

labelled_instruction: LSB! i:ID_LABEL RSB! a:stats (b:labelled_instruction)?
	{#labelled_instruction = #(#[BLOCK,"BLOCK"], ##);}
	//{System.out.println(a.toStringTree());}//registerLeftLabelledInst(i.getText(), new AST[]{factory.dupTree(i).getNextSibling()), factory.dupTree(i.getNextSibling())});}
;

stats: (basic_instruction)+
;
  
basic_instruction: (ID_VAR ASSIG) => ID_VAR ASSIG^ expr
	| IF expr GOTO^ ID_LABEL
	;


// Expressions
expr : (ID_VAR (PLUS|MINUS))=>ID_VAR (PLUS^|MINUS^) ONE
	| ID_VAR DISTINCT^ ZERO
;