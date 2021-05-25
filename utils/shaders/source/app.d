import pegged.grammar;

enum EXGL = `
EXGL:
	Main		< Element{extract}+ eoi

	Element		< Block / Idented(Plain{extract}){extract}

	Block		<{endBlock} '\t'*{startBlock} Plain{extract} Element{extract}*
	Plain		<- Shader / Cond / Vsfs / TexId / SsboId / Assign / Name eol / Import / Define / Data

	Cond		< '!'? Name Block (:Idented("else") Block)?
	Shader		< ;identifier ':' Block{extract}
	Vsfs		< :"vsfs" ;Data

	TexId		< :"__TEX_ID__" ;Data
	SsboId		< :"__SSBO_ID__" ;Data

	Assign		< ;Name '+'? '=' ;Data
	Import		< :"import" ;identifier
	Define		< :"use" ;identifier

	Idented(E)	< '\t'*{checkIdent} E

	Name		<~ [A-Z_]+
	Data		<~ (!eol .)+

	Spacing		<- (' ' / eol)*
`;

enum Extra = `
auto endBlock(ParseTree p)
{
	ident -= p.successful;
	return p;
}

auto startBlock(ParseTree p)
{
	p.successful &= (p.end - p.begin == ident + 1);

	ident += p.successful;
	return p;
}

auto checkIdent(ParseTree p)
{
	p.successful &= (p.end - p.begin == ident);
	return p;
}

auto extract(ParseTree p)
{
	return p.successful ? p.children[0] : p;
}

private __gshared byte ident;
`;

void main()
{
	asModule!(Memoization.no)(`perfontain.shader.grammar`, `../../source/perfontain/shader/grammar`, EXGL, Extra);
}
