%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	#include<math.h>
	extern int line_num;

	int search_symbol(char []);
	void make_symtab_entry(char []);
	void assign_data_type_to_syms(char []);
	void display_sym_tab();
	void addQuadruple(char [],char [],char [],char []);
	void display_Quadruple();
	void push(int);
	int pop();

	struct Quadruple
	{
		char operator[5];
		char operand1[10];
		char operand2[10];
		char result[10];
	}QUAD[25];

	struct Symbol_Table
	{
		char sym_name[10];
		char sym_type[10];
	}Sym[100];

	struct Stack
	{
		int items[25];
		int top;
	}Stk;

	int Index=0,tIndex=0,errno=0,sym_cnt=0;
	int ind1,ind2;
	char prev[10]="-1",curr[10]="-1";
%}

%union{ char arg[10]; }
%token <arg> VARIABLE NUMBER RELOP
%token MAIN
%token INT FLOAT CHAR DOUBLE LONG
%token IF ELSE WHILE FOR
%left '+' '-' 
%left '*' '/'
%type <arg> E ASSIGNMENT CONDITION
%start START

%%
START:PROGRAM  { if(errno==0){
                          printf("\n\n The Program is Syntactically Correct!!!\n\n");
                          display_sym_tab();
                          display_Quadruple();
                     }
                     else {
                          printf("\n\n The No of Errors are : %d \n\n",errno);
			  display_sym_tab();
                     }
               }
PROGRAM:MAIN BLOCK
BLOCK:'{' CODE '}'
CODE:BLOCK|STATEMENT CODE|STATEMENT
STATEMENT:DECLARATIVE ';'|CONDITIONAL|WHILELOOP|ASSIGNMENT ';'|ASSIGNMENT { printf("\n Missing Statement at Line no %d",line_num); errno++;}

DECLARATIVE : INT VARLIST    { assign_data_type_to_syms("int"); }
            | FLOAT VARLIST  { assign_data_type_to_syms("float"); }
            | CHAR VARLIST   { assign_data_type_to_syms("char"); }
	    | DOUBLE VARLIST   { assign_data_type_to_syms("double"); }
	    | LONG VARLIST    { assign_data_type_to_syms("long"); }	

VARLIST:VARIABLE ',' VARLIST { int i;
			       i=search_symbol($1);
                               if(i!=-1) {
 			       errno++;							
                               printf("\n Multiple Declaration of Variable at Line %d \n",line_num+1);		} 
			        else { make_symtab_entry($1); }
                             }
         | VARIABLE  	     { int i;
			       i=search_symbol($1);
                               if(i!=-1) {
 			       errno++;							
                               printf("\n Multiple Declaration of Variable at Line %d \n",line_num+1);		} 
			        else { make_symtab_entry($1); }
                             }

ASSIGNMENT:VARIABLE '=' E    { int i;
                               if(strcmp(prev,curr)!=0) {
                                           i=search_symbol($1);
                                           if(i==-1) {
                                            printf("\n Undefined Variable at Line %d \n",line_num+1);
                                            errno++; 
                                           }  
                                           else if(strcmp(prev,Sym[i].sym_type)!=0) {
                                            printf("\n Type Mismatch at Line %d \n",line_num+1);                                        errno++; 
                                           } 
                                  }                                  
                                  strcpy(QUAD[Index].operator,"=");
                                  strcpy(QUAD[Index].operand1,$3);
                                  strcpy(QUAD[Index].operand2,"");
                                  strcpy(QUAD[Index].result,$1);
                                  strcpy($$,QUAD[Index++].result);
                             }
E: E '+' E   {   if(strcmp(prev,curr)==0) {
                           addQuadruple("+",$1,$3,$$);
                           strcpy(prev,"-1");
                           strcpy(curr,"-1");
                }
                else {
                  printf("\n Type Mismatch at Line %d \n",line_num+1);
                  errno++;    
                }
             }
  |E '-' E   {addQuadruple("-",$1,$3,$$);}  
  |E '*' E   {addQuadruple("*",$1,$3,$$);}  
  |E '/' E   {addQuadruple("/",$1,$3,$$);}  
  |'('E')'   {strcpy($$,$2);}
  |VARIABLE  {   int i;
                 i=search_symbol($1);
                 if(i==-1) {
                        printf("\n Undefined Variable at Line %d \n",line_num+1);
                        errno++; 
                      }  
                 else { 
		 	 if(strcmp(prev,"-1")==0)
                           strcpy(prev,Sym[i].sym_type);
                         else if(strcmp(curr,"-1")==0)
                           strcpy(curr,Sym[i].sym_type);
                      }
             }
   |NUMBER   {  if(strcmp(prev,"-1")==0)
                         strcpy(prev,"int");
                else if(strcmp(curr,"-1")==0)
                         strcpy(curr,"int");
             }

CONDITIONAL :IFSTMT  {   ind1 = pop();
                         sprintf(QUAD[ind1].result,"%d",Index);
                     }
            |IFSTMT  {   strcpy(QUAD[Index].operator,"GOTO");
                         strcpy(QUAD[Index].operand1,"");
                         strcpy(QUAD[Index].operand2,"");
			 strcpy(QUAD[Index].result,"-1");
                         push(Index);
                         Index++;
                      }  ELSESTMT

IFSTMT : IF '(' CONDITION ')'   {    strcpy(QUAD[Index].operator,"==");
                                     strcpy(QUAD[Index].operand1,$3);
                                     strcpy(QUAD[Index].operand2,"FALSE");
                                     strcpy(QUAD[Index].result,"-1");
                                     push(Index);
                                     Index++;
		                } BLOCK

ELSESTMT : ELSE      {   ind1=pop();
	                 ind2=pop();
                         push(ind1);
                         sprintf(QUAD[ind2].result,"%d",Index); 
                     } BLOCK  { 
				ind1=pop();
		                sprintf(QUAD[ind1].result,"%d",Index);
		              }

CONDITION : VARIABLE RELOP VARIABLE   
             {    int i;
		  i=search_symbol($1);
                  if(i==-1)
		  { printf("\n Undefined Variable at Line No: %d \n",line_num);
                    errno++;
                  }
                  i=search_symbol($3);
                  if(i==-1)
                  { printf("\n Undefined Variable at Line No: %d \n",line_num);
                    errno++;
                  }
                  addQuadruple($2,$1,$3,$$);
             }
            |VARIABLE RELOP NUMBER
             {
                int i;
                i=search_symbol($1);
                if(i==-1)
                {
                    printf("\n Undefined Variable at Line No: %d \n",line_num);
                    errno++;
                }
                addQuadruple($2,$1,$3,$$);   
             }

WHILELOOP : WHILESTMT

WHILESTMT : WHILE '(' CONDITION
              {  push(Index-1);
                 strcpy(QUAD[Index].operator,"==");
                 strcpy(QUAD[Index].operand1,$3);
                 strcpy(QUAD[Index].operand2,"FALSE");
                 strcpy(QUAD[Index].result,"-1");
                 push(Index);
                 Index++;
              }
            ')' BLOCK
                {
	           strcpy(QUAD[Index].operator,"GOTO");
	           strcpy(QUAD[Index].operand1,"");
                   strcpy(QUAD[Index].operand2,"");
                   strcpy(QUAD[Index].result,"-1");
                   Index++;
		   ind1 = pop();
                   sprintf(QUAD[ind1].result,"%d",Index);
                   ind2 = pop();
                   sprintf(QUAD[Index-1].result,"%d",ind2);
                }
%%

extern FILE *yyin;
int main(int argc,char *argv[])
{
	FILE *fp;
	Stk.top = -1;
	if(argc < 2) 
	{
		printf("\n\n Invalid No of Arguments!!");
		exit(0);
	}
	yyin = fopen(argv[1],"r");
	yyparse();
	printf("\n\n");
	return(0);
}

int search_symbol(char sym[10])
{
	int i,flag=0;
	for(i=0;i<sym_cnt;i++)
	{
		if(strcmp(Sym[i].sym_name,sym)==0)
		{
			flag=1;
			break;
		}
	}
	if(flag==0)
		return(-1);
	else
		return(i);
}

void make_symtab_entry(char sym[10])
{
	strcpy(Sym[sym_cnt].sym_type,"-1");
	strcpy(Sym[sym_cnt].sym_name,sym);
	sym_cnt++;
}

void assign_data_type_to_syms(char type[10])
{
	int i=sym_cnt-1;
	while(strcmp(Sym[i].sym_type,"-1")==0)
		strcpy(Sym[i--].sym_type,type);
}

void display_sym_tab()
{
	int i;
	printf("\n\n The Symbol Table  \n\n");
	printf(" Name   Type");
	for(i=sym_cnt-1;i>=0;i--)
		printf("\n %s       %s  ",Sym[i].sym_name,Sym[i].sym_type);
}

void addQuadruple(char op[5],char arg1[10],char arg2[10],char res[10])
{
	strcpy(QUAD[Index].operator,op);
	strcpy(QUAD[Index].operand1,arg1);
	strcpy(QUAD[Index].operand2,arg2);
	sprintf(QUAD[Index].result,"t%d",tIndex++);
	strcpy(res,QUAD[Index++].result);
}

void display_Quadruple()
{
	int i;
	printf("\n\n The INTERMEDIATE CODE Is : \n\n");
	printf("\n\n The Quadruple Table \n\n");
	printf("\n     Operator  Operand1  Operand2  Result");
	for(i=0;i<Index;i++)
	{
		printf("\n %d     %s          %s          %s          %s",i,QUAD[i].operator,QUAD[i].operand1,QUAD[i].operand2,QUAD[i].result); 
	}
}

void push(int i)
{
	Stk.top++;
	if(Stk.top==100)
	{
		printf("\nStack OverFlow!! \n");
		exit(0);
	}
	Stk.items[Stk.top] = i;
}

int pop()
{
	int i;
	if(Stk.top==-1)
	{
		printf("\nStack Empty!! \n");
		exit(0);
	}
	i=Stk.items[Stk.top];
	Stk.top--;
	return(i);
}
