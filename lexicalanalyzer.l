%{
	#include<stdio.h>
	#include<stdlib.h>
	#include "y.tab.h"
	int line_num = 0;
%}

%%
void     ;
main\(\)    {return(MAIN);}
int      {return(INT);}
float    {return(FLOAT);}
char     {return(CHAR);}
double	 {return(DOUBLE);}
long	 {return(LONG);}

if        {return(IF);} 
else      {return(ELSE);}
while     {return WHILE;}
for       {return FOR;}

[a-zA-Z][_a-zA-Z0-9]*    { strcpy(yylval.arg,yytext); return(VARIABLE); }
[0-9]+                   { strcpy(yylval.arg,yytext);  return(NUMBER); }
\<|\>|\>=|\<=|==        { strcpy(yylval.arg,yytext);   return(RELOP);  }
[ \t]       ;
"\n"        { ++line_num; }
.           {return(yytext[0]);}  
%%

int yywrap()
{
	return(1);
}

int yyerror(char *s)
{
	printf("\nERROR!! %s at line no. %d",s,line_num);
	return(1);
}
