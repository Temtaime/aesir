module stb.image.write;


extern(C):

alias stbi_write_func = void function(void* context, void* data, int size);

__gshared extern
{
	int stbi_write_tga_with_rle;
	int stbi_write_png_compression_level;
	int stbi_write_force_png_filter;
}

int stbi_write_png(const scope char* filename, int w, int h, int comp, const scope void* data, int stride_in_bytes);
int stbi_write_bmp(const scope char* filename, int w, int h, int comp, const scope void* data);
int stbi_write_tga(const scope char* filename, int w, int h, int comp, const scope void* data);
int stbi_write_hdr(const scope char* filename, int w, int h, int comp, const scope float* data);
int stbi_write_jpg(const scope char* filename, int x, int y, int comp, const scope void* data, int quality);


int stbi_write_png_to_func(stbi_write_func func, void* context, int w, int h, int comp, const scope void* data, int stride_in_bytes);
int stbi_write_bmp_to_func(stbi_write_func func, void* context, int w, int h, int comp, const scope void* data);
int stbi_write_tga_to_func(stbi_write_func func, void* context, int w, int h, int comp, const scope void* data);
int stbi_write_hdr_to_func(stbi_write_func func, void* context, int w, int h, int comp, const scope float* data);
int stbi_write_jpg_to_func(stbi_write_func func, void* context, int x, int y, int comp, const scope void* data, int quality);

void stbi_flip_vertically_on_write(int flip_boolean);
