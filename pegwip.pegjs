{
	
  function extractList(list, index) {
    return list.map(function(element) { return element[index]; });
  }
  
  function buildList(head, tail, index) {
    return [head].concat(extractList(tail, index));
  }
  
  function optionalList(value) {
  	return value !== null ? value : [];
  }
}

Start
  = __ program:Program __ { return program; }

Program
 = body:SourceElements? {
 	return {
    	type: "Program",
        body: optionalList(body)
        }
	}
    
SourceElements
 = head:SourceElement tail:(__ SourceElement)* {
 		return buildList(head,tail,1)
    }
    
SourceElement
 = Statement
 / FunctionDeclaration
 / SourceCharacter
 
Statement
 = Block
 / BreakStatement
 / EmptyStatement
 / VariableStatement
 / list:JSCode+ { return { type:"JS", code:list }}
 
JSCode
 = SourceCharacter { return { type:"JS", code: text() }}

Block
  = LineTerminatorSequence body:(StatementList __)? EndToken {
      return {
        type: "BlockStatement",
        body: optionalList(extractOptional(body, 0))
      };
    }

BreakStatement
  = BreakToken EOS {
      return { type: "BreakStatement", label: null };
    }
  / BreakToken _ label:Identifier EOS {
      return { type: "BreakStatement", label: label };
    }
    
EmptyStatement
 = EndToken { return { type: "EmptyStatement" }; }

VariableStatement
 = VarToken _ AssignmentStatement { return { type: "VariableDeclaration"}; }

AssignmentStatement
 = _ id:Identifier _ AssignToken EOS

StatementList
  = head:Statement tail:(__ Statement)* { return buildList(head, tail, 1); }

FunctionDeclaration
 = FunctionAnon
 / FunctionNamed

FunctionNamed
 = FunctionToken _ identifier:Identifier 
 _? params:(ParamExpression _)? 
 { return { type: "FunctionNamed", id: identifier, params:optionalList(params) }}

FunctionAnon
 = FunctionToken _ AnonToken
 _ params:(ParamExpression _)? 
 _ body:FunctionBody _
 
 { return { type: "FunctionAnon", params:optionalList(params)}}

FunctionBody
 = body:SourceElements? 
 	{
     return {
        type:"BlockStatement",
        body: optionalList(body)
      }
   }

// Tokens
AnonToken = "anon"
FunctionToken = "such"
ParamToken = "much"
EndToken = "wow"
BreakToken = "bork"
VarToken = "very"
AssignToken = "as"

ParamExpression = ParamToken params:ParamList { return params }
ParamList = params:Identifier* { return { type: "Params", params: params }}



WhiteSpace "whitespace"
  = "\t"
  / "\v"
  / "\f"
  / " "
  / "\u00A0"
  / "\uFEFF"
  
__
  = (WhiteSpace / LineTerminatorSequence)*

_
  = (WhiteSpace)*


Identifier = name:([^$A-Z_][0-9A-Z_$]i*) { return { type:"Identifier", val:text() }}

SourceCharacter = . { return text() }

EOS
 = _ LineTerminatorSequence
 / EOF


LineTerminatorSequence "end of line"
  = "\n"
  / "\r\n"
  / "\r"
  / "\u2028"
  / "\u2029"
  
EOF
  = !.