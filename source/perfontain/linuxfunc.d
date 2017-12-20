module perfontain.linuxfunc;

// iconv
alias iconv_t = void *;

iconv_t iconv_open(in char *, in char *);
size_t iconv(iconv_t, void **, size_t *, void **, size_t *);
int iconv_close(iconv_t);









