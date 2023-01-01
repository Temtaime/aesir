module utile.db.mysql.binding;

public import core.stdc.config;

enum
{
	MYSQL_OPT_CONNECT_TIMEOUT,
	MYSQL_OPT_COMPRESS,
	MYSQL_OPT_NAMED_PIPE,
	MYSQL_INIT_COMMAND,
	MYSQL_READ_DEFAULT_FILE,
	MYSQL_READ_DEFAULT_GROUP,
	MYSQL_SET_CHARSET_DIR,
	MYSQL_SET_CHARSET_NAME,
	MYSQL_OPT_LOCAL_INFILE,
	MYSQL_OPT_PROTOCOL,
	MYSQL_SHARED_MEMORY_BASE_NAME,
	MYSQL_OPT_READ_TIMEOUT,
	MYSQL_OPT_WRITE_TIMEOUT,
	MYSQL_OPT_USE_RESULT,
	MYSQL_OPT_USE_REMOTE_CONNECTION,
	MYSQL_OPT_USE_EMBEDDED_CONNECTION,
	MYSQL_OPT_GUESS_CONNECTION,
	MYSQL_SET_CLIENT_IP,
	MYSQL_SECURE_AUTH,
	MYSQL_REPORT_DATA_TRUNCATION,
	MYSQL_OPT_RECONNECT,
	MYSQL_OPT_SSL_VERIFY_SERVER_CERT,
	MYSQL_PLUGIN_DIR,
	MYSQL_DEFAULT_AUTH,
	MYSQL_OPT_BIND,
	MYSQL_OPT_SSL_KEY,
	MYSQL_OPT_SSL_CERT,
	MYSQL_OPT_SSL_CA,
	MYSQL_OPT_SSL_CAPATH,
	MYSQL_OPT_SSL_CIPHER,
	MYSQL_OPT_SSL_CRL,
	MYSQL_OPT_SSL_CRLPATH,
	MYSQL_OPT_CONNECT_ATTR_RESET,
	MYSQL_OPT_CONNECT_ATTR_ADD,
	MYSQL_OPT_CONNECT_ATTR_DELETE,
	MYSQL_SERVER_PUBLIC_KEY,
	MYSQL_ENABLE_CLEARTEXT_PLUGIN,
	MYSQL_OPT_CAN_HANDLE_EXPIRED_PASSWORDS,
	MYSQL_OPT_SSL_ENFORCE,
	MYSQL_OPT_MAX_ALLOWED_PACKET,
	MYSQL_OPT_NET_BUFFER_LENGTH,
	MYSQL_OPT_TLS_VERSION,
	MYSQL_OPT_SSL_MODE
}

enum
{
	MYSQL_STATUS_READY,
	MYSQL_STATUS_GET_RESULT,
	MYSQL_STATUS_USE_RESULT,
	MYSQL_STATUS_STATEMENT_GET_RESULT
}

enum
{
	MYSQL_PROTOCOL_DEFAULT,
	MYSQL_PROTOCOL_TCP,
	MYSQL_PROTOCOL_SOCKET,
	MYSQL_PROTOCOL_PIPE,
	MYSQL_PROTOCOL_MEMORY
}

enum
{
	SSL_MODE_DISABLED = 1,
	SSL_MODE_PREFERRED,
	SSL_MODE_REQUIRED,
	SSL_MODE_VERIFY_CA,
	SSL_MODE_VERIFY_IDENTITY
}

enum
{
	MYSQL_STMT_INIT_DONE = 1,
	MYSQL_STMT_PREPARE_DONE,
	MYSQL_STMT_EXECUTE_DONE,
	MYSQL_STMT_FETCH_DONE
}

enum
{
	STMT_ATTR_UPDATE_MAX_LENGTH,
	STMT_ATTR_CURSOR_TYPE,
	STMT_ATTR_PREFETCH_ROWS
}

enum
{
	MYSQL_TYPE_DECIMAL,
	MYSQL_TYPE_TINY,
	MYSQL_TYPE_SHORT,
	MYSQL_TYPE_LONG,
	MYSQL_TYPE_FLOAT,
	MYSQL_TYPE_DOUBLE,
	MYSQL_TYPE_NULL,
	MYSQL_TYPE_TIMESTAMP,
	MYSQL_TYPE_LONGLONG,
	MYSQL_TYPE_INT24,
	MYSQL_TYPE_DATE,
	MYSQL_TYPE_TIME,
	MYSQL_TYPE_DATETIME,
	MYSQL_TYPE_YEAR,
	MYSQL_TYPE_NEWDATE,
	MYSQL_TYPE_VARCHAR,
	MYSQL_TYPE_BIT,
	MYSQL_TYPE_TIMESTAMP2,
	MYSQL_TYPE_DATETIME2,
	MYSQL_TYPE_TIME2,
	MYSQL_TYPE_JSON = 245,
	MYSQL_TYPE_NEWDECIMAL = 246,
	MYSQL_TYPE_ENUM = 247,
	MYSQL_TYPE_SET = 248,
	MYSQL_TYPE_TINY_BLOB = 249,
	MYSQL_TYPE_MEDIUM_BLOB = 250,
	MYSQL_TYPE_LONG_BLOB = 251,
	MYSQL_TYPE_BLOB = 252,
	MYSQL_TYPE_VAR_STRING = 253,
	MYSQL_TYPE_STRING = 254,
	MYSQL_TYPE_GEOMETRY = 255
}

enum
{
	MYSQL_NO_DATA = 100,
	MYSQL_DATA_TRUNCATED
}

alias NET = void;
alias MYSQL = void;
alias MYSQL_ROW = char**;
alias MYSQL_FIELD_OFFSET = uint;
alias MYSQL_ROW_OFFSET = MYSQL_ROWS*;

extern (System):

struct MYSQL_FIELD
{
	char* name;
	char* org_name;
	char* table;
	char* org_table;
	char* db;
	char* catalog;
	char* def;
	c_ulong length;
	c_ulong max_length;
	uint name_length;
	uint org_name_length;
	uint table_length;
	uint org_table_length;
	uint db_length;
	uint catalog_length;
	uint def_length;
	uint flags;
	uint decimals;
	uint charsetnr;
	int type;
	void* extension;
}

struct MYSQL_ROWS
{
	MYSQL_ROWS* next;
	MYSQL_ROW data;
	c_ulong length;
}

struct USED_MEM
{
	USED_MEM* next;
	uint left;
	uint size;
}

struct LIST
{
	LIST* prev, next;
	void* data;
}

struct MEM_ROOT
{
	USED_MEM* free;
	USED_MEM* used;
	USED_MEM* pre_alloc;
	size_t min_malloc;
	size_t block_size;
	uint block_num;
	uint first_block_usage;

	void function() error_handler;

	uint m_psi_key;
}

struct MYSQL_DATA
{
	MYSQL_ROWS* data;
	void* embedded_info;
	MEM_ROOT alloc;
	ulong rows;
	uint fields;
	void* extension;
}

struct MY_CHARSET_INFO
{
	uint number;
	uint state;
	const(char)* csname;
	const(char)* name;
	const(char)* comment;
	const(char)* dir;
	uint mbminlen;
	uint mbmaxlen;
}

struct MYSQL_RES
{
	ulong row_count;
	MYSQL_FIELD* fields;
	MYSQL_DATA* data;
	MYSQL_ROWS* data_cursor;
	c_ulong* lengths;
	MYSQL* handle;
	const(void)* methods;
	MYSQL_ROW row;
	MYSQL_ROW current_row;
	MEM_ROOT field_alloc;
	uint field_count, current_field;
	bool eof;

	bool unbuffered_fetch_cancelled;
	void* extension;
}

struct MYSQL_PARAMETERS
{
	c_ulong* p_max_allowed_packet;
	c_ulong* p_net_buffer_length;
	void* extension;
}

struct MYSQL_BIND
{
	c_ulong* length;
	bool* is_null;
	void* buffer;

	bool* error;
	ubyte* row_ptr;

	void function(NET* net, MYSQL_BIND* param) store_param_func;
	void function(MYSQL_BIND*, MYSQL_FIELD*, ubyte** row) fetch_result;
	void function(MYSQL_BIND*, MYSQL_FIELD*, ubyte** row) skip_result;

	c_ulong buffer_length;
	c_ulong offset;
	c_ulong length_value;
	uint param_number;
	uint pack_length;
	int buffer_type;
	bool error_value;
	bool is_unsigned;
	bool long_data_used;
	bool is_null_value;
	void* extension;
}

struct MYSQL_STMT
{
	MEM_ROOT mem_root;
	LIST list;
	MYSQL* mysql;
	MYSQL_BIND* params;
	MYSQL_BIND* bind;
	MYSQL_FIELD* fields;
	MYSQL_DATA result;
	MYSQL_ROWS* data_cursor;

	int function(MYSQL_STMT* stmt, ubyte** row) read_row_func;

	ulong affected_rows;
	ulong insert_id;
	c_ulong stmt_id;
	c_ulong flags;
	c_ulong prefetch_rows;

	uint server_status;
	uint last_errno;
	uint param_count;
	uint field_count;
	int state;
	char[512] last_error;
	char[5 + 1] sqlstate;

	bool send_types_to_server;
	bool bind_param_done;
	ubyte bind_result_done;

	bool unbuffered_fetch_cancelled;
	bool update_max_length;
	void* extension;
}

bool my_init();

MYSQL_PARAMETERS* mysql_get_parameters();

int mysql_server_init(int argc, char** argv, char** groups);
void mysql_server_end();

bool mysql_thread_init();
void mysql_thread_end();

ulong mysql_num_rows(MYSQL_RES* res);
uint mysql_num_fields(MYSQL_RES* res);
bool mysql_eof(MYSQL_RES* res);
MYSQL_FIELD* mysql_fetch_field_direct(MYSQL_RES* res, uint fieldnr);
MYSQL_FIELD* mysql_fetch_fields(MYSQL_RES* res);
MYSQL_ROW_OFFSET mysql_row_tell(MYSQL_RES* res);
MYSQL_FIELD_OFFSET mysql_field_tell(MYSQL_RES* res);

uint mysql_field_count(MYSQL* mysql);
ulong mysql_affected_rows(MYSQL* mysql);
ulong mysql_insert_id(MYSQL* mysql);
uint mysql_errno(MYSQL* mysql);
const(char)* mysql_error(MYSQL* mysql);
const(char)* mysql_sqlstate(MYSQL* mysql);
uint mysql_warning_count(MYSQL* mysql);
const(char)* mysql_info(MYSQL* mysql);
c_ulong mysql_thread_id(MYSQL* mysql);
const(char)* mysql_character_set_name(MYSQL* mysql);
int mysql_set_character_set(MYSQL* mysql, const(char)* csname);

MYSQL* mysql_init(MYSQL* mysql);
bool mysql_ssl_set(MYSQL* mysql, const(char)* key, const(char)* cert,
		const(char)* ca, const(char)* capath, const(char)* cipher);

const(char)* mysql_get_ssl_cipher(MYSQL* mysql);
bool mysql_change_user(MYSQL* mysql, const(char)* user, const(char)* passwd, const(char)* db);

MYSQL* mysql_real_connect(MYSQL* mysql, const(char)* host, const(char)* user,
		const(char)* passwd, const(char)* db, uint port,
		const(char)* unix_socket, c_ulong clientflag);

int mysql_select_db(MYSQL* mysql, const(char)* db);
int mysql_query(MYSQL* mysql, const(char)* q);
int mysql_send_query(MYSQL* mysql, const(char)* q, c_ulong length);
int mysql_real_query(MYSQL* mysql, const(char)* q, c_ulong length);
MYSQL_RES* mysql_store_result(MYSQL* mysql);
MYSQL_RES* mysql_use_result(MYSQL* mysql);

void mysql_get_character_set_info(MYSQL* mysql, MY_CHARSET_INFO* charset);

int mysql_session_track_get_first(MYSQL* mysql, int type, const(char)** data, size_t* length);
int mysql_session_track_get_next(MYSQL* mysql, int type, const(char)** data, size_t* length);

void mysql_set_local_infile_handler(MYSQL* mysql, int function(void**,
		const(char)*, void*) local_infile_init, int function(void*, char*, uint) local_infile_read,
		void function(void*) local_infile_end, int function(void*, char*,
			uint) local_infile_error, void*);

void mysql_set_local_infile_default(MYSQL* mysql);

int mysql_shutdown(MYSQL* mysql, int shutdown_level);
int mysql_dump_debug_info(MYSQL* mysql);
int mysql_refresh(MYSQL* mysql, uint refresh_options);
int mysql_kill(MYSQL* mysql, c_ulong pid);
int mysql_set_server_option(MYSQL* mysql, int option);
int mysql_ping(MYSQL* mysql);
const(char)* mysql_stat(MYSQL* mysql);
const(char)* mysql_get_server_info(MYSQL* mysql);
const(char)* mysql_get_client_info();
c_ulong mysql_get_client_version();
const(char)* mysql_get_host_info(MYSQL* mysql);
c_ulong mysql_get_server_version(MYSQL* mysql);
uint mysql_get_proto_info(MYSQL* mysql);
MYSQL_RES* mysql_list_dbs(MYSQL* mysql, const(char)* wild);
MYSQL_RES* mysql_list_tables(MYSQL* mysql, const(char)* wild);
MYSQL_RES* mysql_list_processes(MYSQL* mysql);
int mysql_options(MYSQL* mysql, int option, const(void)* arg);
int mysql_options4(MYSQL* mysql, int option, const(void)* arg1, const(void)* arg2);
int mysql_get_option(MYSQL* mysql, int option, const(void)* arg);
void mysql_free_result(MYSQL_RES* result);
void mysql_data_seek(MYSQL_RES* result, ulong offset);
MYSQL_ROW_OFFSET mysql_row_seek(MYSQL_RES* result, MYSQL_ROW_OFFSET offset);
MYSQL_FIELD_OFFSET mysql_field_seek(MYSQL_RES* result, MYSQL_FIELD_OFFSET offset);
MYSQL_ROW mysql_fetch_row(MYSQL_RES* result);
c_ulong* mysql_fetch_lengths(MYSQL_RES* result);
MYSQL_FIELD* mysql_fetch_field(MYSQL_RES* result);
MYSQL_RES* mysql_list_fields(MYSQL* mysql, const(char)* table, const(char)* wild);
c_ulong mysql_escape_string(char* to, const(char)* from, c_ulong from_length);
c_ulong mysql_hex_string(char* to, const(char)* from, c_ulong from_length);
c_ulong mysql_real_escape_string(MYSQL* mysql, char* to, const(char)* from, c_ulong length);
c_ulong mysql_real_escape_string_quote(MYSQL* mysql, char* to,
		const(char)* from, c_ulong length, char quote);
void mysql_debug(const(char)* debug_);
void myodbc_remove_escape(MYSQL* mysql, char* name);
uint mysql_thread_safe();
bool mysql_embedded();
bool mysql_read_query_result(MYSQL* mysql);
int mysql_reset_connection(MYSQL* mysql);

MYSQL_STMT* mysql_stmt_init(MYSQL* mysql);
int mysql_stmt_prepare(MYSQL_STMT* stmt, const(char)* query, c_ulong length);
int mysql_stmt_execute(MYSQL_STMT* stmt);
int mysql_stmt_fetch(MYSQL_STMT* stmt);
int mysql_stmt_fetch_column(MYSQL_STMT* stmt, MYSQL_BIND* bind_arg, uint column, c_ulong offset);
int mysql_stmt_store_result(MYSQL_STMT* stmt);
c_ulong mysql_stmt_param_count(MYSQL_STMT* stmt);
bool mysql_stmt_attr_set(MYSQL_STMT* stmt, int attr_type, const(void)* attr);
bool mysql_stmt_attr_get(MYSQL_STMT* stmt, int attr_type, void* attr);
bool mysql_stmt_bind_param(MYSQL_STMT* stmt, MYSQL_BIND* bnd);
bool mysql_stmt_bind_result(MYSQL_STMT* stmt, MYSQL_BIND* bnd);
bool mysql_stmt_close(MYSQL_STMT* stmt);
bool mysql_stmt_reset(MYSQL_STMT* stmt);
bool mysql_stmt_free_result(MYSQL_STMT* stmt);
bool mysql_stmt_send_long_data(MYSQL_STMT* stmt, uint param_number,
		const(char)* data, c_ulong length);
MYSQL_RES* mysql_stmt_result_metadata(MYSQL_STMT* stmt);
MYSQL_RES* mysql_stmt_param_metadata(MYSQL_STMT* stmt);
uint mysql_stmt_errno(MYSQL_STMT* stmt);
const(char)* mysql_stmt_error(MYSQL_STMT* stmt);
const(char)* mysql_stmt_sqlstate(MYSQL_STMT* stmt);
MYSQL_ROW_OFFSET mysql_stmt_row_seek(MYSQL_STMT* stmt, MYSQL_ROW_OFFSET offset);
MYSQL_ROW_OFFSET mysql_stmt_row_tell(MYSQL_STMT* stmt);
void mysql_stmt_data_seek(MYSQL_STMT* stmt, ulong offset);
ulong mysql_stmt_num_rows(MYSQL_STMT* stmt);
ulong mysql_stmt_affected_rows(MYSQL_STMT* stmt);
ulong mysql_stmt_insert_id(MYSQL_STMT* stmt);
uint mysql_stmt_field_count(MYSQL_STMT* stmt);

bool mysql_commit(MYSQL* mysql);
bool mysql_rollback(MYSQL* mysql);
bool mysql_autocommit(MYSQL* mysql, bool auto_mode);
bool mysql_more_results(MYSQL* mysql);
int mysql_next_result(MYSQL* mysql);
int mysql_stmt_next_result(MYSQL_STMT* stmt);
void mysql_close(MYSQL* sock);
