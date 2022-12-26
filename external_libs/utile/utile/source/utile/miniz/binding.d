module utile.miniz.binding;

import core.stdc.stdio;

extern (C):

enum
{
	MZ_ZIP_MAX_IO_BUF_SIZE = 64 * 1024,
	MZ_ZIP_MAX_ARCHIVE_FILENAME_SIZE = 512,
	MZ_ZIP_MAX_ARCHIVE_FILE_COMMENT_SIZE = 512
}

struct mz_zip_internal_state;

struct mz_zip_archive_file_stat
{
	uint m_file_index;
	ulong m_central_dir_ofs;
	ushort m_version_made_by;
	ushort m_version_needed;
	ushort m_bit_flag;
	ushort m_method;
	ulong m_time;
	uint m_crc32;
	ulong m_comp_size;
	ulong m_uncomp_size;
	ushort m_internal_attr;
	uint m_external_attr;
	ulong m_local_header_ofs;
	uint m_comment_size;
	int m_is_directory;
	int m_is_encrypted;
	int m_is_supported;
	char[MZ_ZIP_MAX_ARCHIVE_FILENAME_SIZE] m_filename;
	char[MZ_ZIP_MAX_ARCHIVE_FILE_COMMENT_SIZE] m_comment;
}

struct mz_zip_archive
{
	ulong m_archive_size;
	ulong m_central_directory_file_ofs;
	uint m_total_files;
	mz_zip_mode m_zip_mode;
	mz_zip_type m_zip_type;
	mz_zip_error m_last_error;
	ulong m_file_offset_alignment;
	mz_alloc_func m_pAlloc;
	mz_free_func m_pFree;
	mz_realloc_func m_pRealloc;
	void* m_pAlloc_opaque;
	mz_file_read_func m_pRead;
	mz_file_write_func m_pWrite;
	mz_file_needs_keepalive m_pNeeds_keepalive;
	void* m_pIO_opaque;
	mz_zip_internal_state* m_pState;
}

/*struct tinfl_decompressor;

struct mz_zip_reader_extract_iter_state
{
	mz_zip_archive* pZip;
	uint flags;
	int status;
	uint mz_file_crc32;
	ulong read_buf_size, read_buf_ofs, read_buf_avail, comp_remaining, out_buf_ofs, cur_file_ofs;
	mz_zip_archive_file_stat mz_file_stat;
	void* pRead_buf;
	void* pWrite_buf;
	size_t out_blk_remain;
	tinfl_decompressor inflator;
}*/

alias mz_file_read_func = size_t function(void* pOpaque, ulong mz_file_ofs, void* pBuf, size_t n);
alias mz_file_write_func = size_t function(void* pOpaque, ulong mz_file_ofs, const scope void* pBuf, size_t n);
alias mz_file_needs_keepalive = int function(void* pOpaque);

alias mz_alloc_func = void* function(void* opaque, size_t items, size_t size);
alias mz_free_func = void function(void* opaque, void* address);
alias mz_realloc_func = void* function(void* opaque, void* address, size_t items, size_t size);

alias mz_zip_mode = int;
alias mz_zip_type = int;
alias mz_zip_error = int;
alias mz_zip_flags = int;

enum
{
	MZ_ZIP_MODE_INVALID = 0,
	MZ_ZIP_MODE_READING = 1,
	MZ_ZIP_MODE_WRITING = 2,
	MZ_ZIP_MODE_WRITING_HAS_BEEN_FINALIZED = 3
}

enum
{
	MZ_ZIP_FLAG_CASE_SENSITIVE = 0x0100,
	MZ_ZIP_FLAG_IGNORE_PATH = 0x0200,
	MZ_ZIP_FLAG_COMPRESSED_DATA = 0x0400,
	MZ_ZIP_FLAG_DO_NOT_SORT_CENTRAL_DIRECTORY = 0x0800,
	MZ_ZIP_FLAG_VALIDATE_LOCATE_FILE_FLAG = 0x1000,
	MZ_ZIP_FLAG_VALIDATE_HEADERS_ONLY = 0x2000,
	MZ_ZIP_FLAG_WRITE_ZIP64 = 0x4000,
	MZ_ZIP_FLAG_WRITE_ALLOW_READING = 0x8000,
	MZ_ZIP_FLAG_ASCII_FILENAME = 0x10000
}

enum
{
	MZ_ZIP_TYPE_INVALID = 0,
	MZ_ZIP_TYPE_USER,
	MZ_ZIP_TYPE_MEMORY,
	MZ_ZIP_TYPE_HEAP,
	MZ_ZIP_TYPE_FILE,
	MZ_ZIP_TYPE_CFILE,
	MZ_ZIP_TOTAL_TYPES
}

enum
{
	MZ_ZIP_NO_ERROR = 0,
	MZ_ZIP_UNDEFINED_ERROR,
	MZ_ZIP_TOO_MANY_FILES,
	MZ_ZIP_FILE_TOO_LARGE,
	MZ_ZIP_UNSUPPORTED_METHOD,
	MZ_ZIP_UNSUPPORTED_ENCRYPTION,
	MZ_ZIP_UNSUPPORTED_FEATURE,
	MZ_ZIP_FAILED_FINDING_CENTRAL_DIR,
	MZ_ZIP_NOT_AN_ARCHIVE,
	MZ_ZIP_INVALID_HEADER_OR_CORRUPTED,
	MZ_ZIP_UNSUPPORTED_MULTIDISK,
	MZ_ZIP_DECOMPRESSION_FAILED,
	MZ_ZIP_COMPRESSION_FAILED,
	MZ_ZIP_UNEXPECTED_DECOMPRESSED_SIZE,
	MZ_ZIP_CRC_CHECK_FAILED,
	MZ_ZIP_UNSUPPORTED_CDIR_SIZE,
	MZ_ZIP_ALLOC_FAILED,
	MZ_ZIP_FILE_OPEN_FAILED,
	MZ_ZIP_FILE_CREATE_FAILED,
	MZ_ZIP_FILE_WRITE_FAILED,
	MZ_ZIP_FILE_READ_FAILED,
	MZ_ZIP_FILE_CLOSE_FAILED,
	MZ_ZIP_FILE_SEEK_FAILED,
	MZ_ZIP_FILE_STAT_FAILED,
	MZ_ZIP_INVALID_PARAMETER,
	MZ_ZIP_INVALID_FILENAME,
	MZ_ZIP_BUF_TOO_SMALL,
	MZ_ZIP_INTERNAL_ERROR,
	MZ_ZIP_FILE_NOT_FOUND,
	MZ_ZIP_ARCHIVE_TOO_LARGE,
	MZ_ZIP_VALIDATION_FAILED,
	MZ_ZIP_WRITE_CALLBACK_FAILED,
	MZ_ZIP_TOTAL_ERRORS
}

int mz_zip_reader_init(mz_zip_archive* pZip, ulong size, uint flags);
int mz_zip_reader_init_mem(mz_zip_archive* pZip, const scope void* pMem, size_t size, uint flags);
int mz_zip_reader_init_file(mz_zip_archive* pZip, const scope char* pFilename, uint flags);
int mz_zip_reader_init_file_v2(mz_zip_archive* pZip, const scope char* pFilename,
		uint flags, ulong mz_file_start_ofs, ulong archive_size);
int mz_zip_reader_init_cfile(mz_zip_archive* pZip, FILE* pFile, ulong archive_size, uint flags);

int mz_zip_reader_end(mz_zip_archive* pZip);
void mz_zip_zero_struct(mz_zip_archive* pZip);

mz_zip_mode mz_zip_get_mode(mz_zip_archive* pZip);
mz_zip_type mz_zip_get_type(mz_zip_archive* pZip);
uint mz_zip_reader_get_num_files(mz_zip_archive* pZip);
ulong mz_zip_get_archive_size(mz_zip_archive* pZip);
ulong mz_zip_get_archive_file_start_offset(mz_zip_archive* pZip);

FILE* mz_zip_get_cfile(mz_zip_archive* pZip);
size_t mz_zip_read_archive_data(mz_zip_archive* pZip, ulong mz_file_ofs, void* pBuf, size_t n);

mz_zip_error mz_zip_set_last_error(mz_zip_archive* pZip, mz_zip_error err_num);
mz_zip_error mz_zip_peek_last_error(mz_zip_archive* pZip);
mz_zip_error mz_zip_clear_last_error(mz_zip_archive* pZip);
mz_zip_error mz_zip_get_last_error(mz_zip_archive* pZip);
const(char)* mz_zip_get_error_string(mz_zip_error mz_err);

int mz_zip_reader_is_file_a_directory(mz_zip_archive* pZip, uint mz_file_index);
int mz_zip_reader_is_file_encrypted(mz_zip_archive* pZip, uint mz_file_index);
int mz_zip_reader_is_file_supported(mz_zip_archive* pZip, uint mz_file_index);

uint mz_zip_reader_get_filename(mz_zip_archive* pZip, uint mz_file_index,
		char* pFilename, uint filename_buf_size);

int mz_zip_reader_locate_file(mz_zip_archive* pZip, const scope char* pName, const scope char* pComment, uint flags);
int mz_zip_reader_locate_file_v2(mz_zip_archive* pZip, const scope char* pName,
		const scope char* pComment, uint flags, uint* mz_file_index);
int mz_zip_reader_file_stat(mz_zip_archive* pZip, uint mz_file_index,
		mz_zip_archive_file_stat* pStat);

int mz_zip_is_zip64(mz_zip_archive* pZip);
size_t mz_zip_get_central_dir_size(mz_zip_archive* pZip);

int mz_zip_reader_extract_to_mem_no_alloc(mz_zip_archive* pZip, uint mz_file_index,
		void* pBuf, size_t buf_size, uint flags, void* pUser_read_buf, size_t user_read_buf_size);
int mz_zip_reader_extract_file_to_mem_no_alloc(mz_zip_archive* pZip, const scope char* pFilename,
		void* pBuf, size_t buf_size, uint flags, void* pUser_read_buf, size_t user_read_buf_size);
int mz_zip_reader_extract_to_mem(mz_zip_archive* pZip, uint mz_file_index,
		void* pBuf, size_t buf_size, uint flags);
int mz_zip_reader_extract_file_to_mem(mz_zip_archive* pZip, const scope char* pFilename,
		void* pBuf, size_t buf_size, uint flags);

void* mz_zip_reader_extract_to_heap(mz_zip_archive* pZip, uint mz_file_index,
		size_t* pSize, uint flags);
void* mz_zip_reader_extract_file_to_heap(mz_zip_archive* pZip,
		const scope char* pFilename, size_t* pSize, uint flags);

int mz_zip_reader_extract_to_callback(mz_zip_archive* pZip, uint mz_file_index,
		mz_file_write_func pCallback, void* pOpaque, uint flags);
int mz_zip_reader_extract_file_to_callback(mz_zip_archive* pZip,
		const scope char* pFilename, mz_file_write_func pCallback, void* pOpaque, uint flags);

/*mz_zip_reader_extract_iter_state* mz_zip_reader_extract_iter_new(mz_zip_archive* pZip, uint mz_file_index, uint flags);
mz_zip_reader_extract_iter_state* mz_zip_reader_extract_file_iter_new(mz_zip_archive* pZip, const scope char* pFilename, uint flags);
size_t mz_zip_reader_extract_iter_read(mz_zip_reader_extract_iter_state* pState, void* pvBuf, size_t buf_size);
int mz_zip_reader_extract_iter_free(mz_zip_reader_extract_iter_state* pState);*/

int mz_zip_reader_extract_to_file(mz_zip_archive* pZip, uint mz_file_index,
		const scope char* pDst_filename, uint flags);
int mz_zip_reader_extract_file_to_file(mz_zip_archive* pZip,
		const scope char* pArchive_filename, const scope char* pDst_filename, uint flags);
int mz_zip_reader_extract_to_cfile(mz_zip_archive* pZip, uint mz_file_index, FILE* File, uint flags);
int mz_zip_reader_extract_file_to_cfile(mz_zip_archive* pZip,
		const scope char* pArchive_filename, FILE* pFile, uint flags);

int mz_zip_validate_file(mz_zip_archive* pZip, uint mz_file_index, uint flags);
int mz_zip_validate_archive(mz_zip_archive* pZip, uint flags);
int mz_zip_validate_mem_archive(const scope void* pMem, size_t size, uint flags, mz_zip_error* pErr);
int mz_zip_validate_file_archive(const scope char* pFilename, uint flags, mz_zip_error* pErr);
int mz_zip_end(mz_zip_archive* pZip);

int mz_zip_writer_init(mz_zip_archive* pZip, ulong existing_size);
int mz_zip_writer_init_v2(mz_zip_archive* pZip, ulong existing_size, uint flags);
int mz_zip_writer_init_heap(mz_zip_archive* pZip,
		size_t size_to_reserve_at_beginning, size_t initial_allocation_size);
int mz_zip_writer_init_heap_v2(mz_zip_archive* pZip,
		size_t size_to_reserve_at_beginning, size_t initial_allocation_size, uint flags);
int mz_zip_writer_init_file(mz_zip_archive* pZip, const scope char* pFilename,
		ulong size_to_reserve_at_beginning);
int mz_zip_writer_init_file_v2(mz_zip_archive* pZip, const scope char* pFilename,
		ulong size_to_reserve_at_beginning, uint flags);
int mz_zip_writer_init_cfile(mz_zip_archive* pZip, FILE* pFile, uint flags);
int mz_zip_writer_init_from_reader(mz_zip_archive* pZip, const scope char* pFilename);
int mz_zip_writer_init_from_reader_v2(mz_zip_archive* pZip, const scope char* pFilename, uint flags);

int mz_zip_writer_add_mem(mz_zip_archive* pZip, const scope char* pArchive_name,
		const scope void* pBuf, size_t buf_size, uint level_and_flags);
int mz_zip_writer_add_mem_ex(mz_zip_archive* pZip, const scope char* pArchive_name, const scope void* pBuf, size_t buf_size,
		const scope void* pComment, ushort comment_size, uint level_and_flags,
		ulong uncomp_size, uint uncomp_crc32);
int mz_zip_writer_add_mem_ex_v2(mz_zip_archive* pZip, const scope char* pArchive_name, const scope void* pBuf, size_t buf_size,
		const scope void* pComment, ushort comment_size, uint level_and_flags,
		ulong uncomp_size, uint uncomp_crc32, ulong* last_modified,
		const scope char* user_extra_data_local,
		uint user_extra_data_local_len, const scope char* user_extra_data_central,
		uint user_extra_data_central_len);

int mz_zip_writer_add_file(mz_zip_archive* pZip, const scope char* pArchive_name,
		const scope char* pSrc_filename, const scope void* pComment, ushort comment_size, uint level_and_flags);
int mz_zip_writer_add_cfile(mz_zip_archive* pZip, const scope char* pArchive_name, FILE* pSrc_file, ulong size_to_add,
		const scope ulong* pFile_time, const scope void* pComment, ushort comment_size, uint level_and_flags, const scope char* user_extra_data_local,
		uint user_extra_data_local_len, const scope char* user_extra_data_central,
		uint user_extra_data_central_len);
int mz_zip_writer_add_from_zip_reader(mz_zip_archive* pZip,
		mz_zip_archive* pSource_zip, uint src_file_index);

int mz_zip_writer_finalize_archive(mz_zip_archive* pZip);
int mz_zip_writer_finalize_heap_archive(mz_zip_archive* pZip, void** ppBuf, size_t* pSize);
int mz_zip_writer_end(mz_zip_archive* pZip);

int mz_zip_add_mem_to_archive_file_in_place(const scope char* pZip_filename, const scope char* pArchive_name,
		const scope void* pBuf, size_t buf_size, const scope void* pComment, ushort comment_size, uint level_and_flags);
int mz_zip_add_mem_to_archive_file_in_place_v2(const scope char* pZip_filename, const scope char* pArchive_name, const scope void* pBuf,
		size_t buf_size, const scope void* pComment, ushort comment_size,
		uint level_and_flags, mz_zip_error* pErr);

void* mz_zip_extract_archive_file_to_heap(const scope char* pZip_filename,
		const scope char* pArchive_name, size_t* pSize, uint flags);
void* mz_zip_extract_archive_file_to_heap_v2(const scope char* pZip_filename,
		const scope char* pArchive_name, const scope char* pComment, size_t* pSize, uint flags, mz_zip_error* pErr);
