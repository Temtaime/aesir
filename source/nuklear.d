module nuklear;

public import
				core.stdc.stdarg,
				core.stdc.config;

extern(C):

/* int nk_strmatch_fuzzy_string(char const *str, char const *pattern, int *out_score); */

/* int nk_textedit_paste(struct nk_text_edit*, char const*, int len); */

static immutable NK_VERTEX_LAYOUT_END = nk_draw_vertex_layout_element(NK_VERTEX_ATTRIBUTE_COUNT, NK_FORMAT_COUNT, 0);

enum NK_UTF_SIZE = 4;

alias byte nk_char;
alias ubyte nk_uchar;
alias ubyte nk_byte;
alias short nk_short;
alias ushort nk_ushort;
alias int nk_int;
alias uint nk_uint;
alias size_t nk_size;
alias size_t nk_ptr;
alias nk_uint nk_hash;
alias nk_uint nk_flags;
alias nk_uint nk_rune;

alias char[4] nk_glyph;
alias void* function(nk_handle, void* old, nk_size) nk_plugin_alloc;
alias void function(nk_handle, void* old) nk_plugin_free;
alias int function(const(nk_text_edit)*, nk_rune unicode) nk_plugin_filter;
alias void function(nk_handle, nk_text_edit*) nk_plugin_paste;
alias void function(nk_handle, const(char)*, int len) nk_plugin_copy;
alias float function(nk_handle, float h, const(char)*, int len) nk_text_width_f;
alias void function(nk_handle handle, float font_height, nk_user_font_glyph* glyph, nk_rune codepoint, nk_rune next_codepoint) nk_query_font_glyph_f;
alias void function(void* canvas, short x, short y, ushort w, ushort h, nk_handle callback_data) nk_command_custom_callback;
alias nk_uint nk_draw_index;

alias nk_heading = int;
alias nk_button_behavior = int;
alias nk_modify = int;
alias nk_orientation = int;
alias nk_collapse_states = int;
alias nk_show_states = int;
alias nk_chart_type = int;
alias nk_chart_event = int;
alias nk_color_format = int;
alias nk_popup_type = int;
alias nk_layout_format = int;
alias nk_tree_type = int;
alias nk_symbol_type = int;
alias nk_keys = int;
alias nk_buttons = int;
alias nk_anti_aliasing = int;
alias nk_convert_result = int;
alias nk_panel_flags = int;
alias nk_widget_layout_states = int;
alias nk_widget_states = int;
alias nk_text_align = int;
alias nk_text_alignment = int;
alias nk_edit_flags = int;
alias nk_edit_types = int;
alias nk_edit_events = int;
alias nk_style_colors = int;
alias nk_style_cursor = int;
alias nk_font_coord_type = int;
alias nk_font_atlas_format = int;
alias nk_allocation_type = int;
alias nk_buffer_allocation_type = int;
alias nk_text_edit_type = int;
alias nk_text_edit_mode = int;
alias nk_command_type = int;
alias nk_command_clipping = int;
alias nk_draw_list_stroke = int;
alias nk_draw_vertex_layout_attribute = int;
alias nk_draw_vertex_layout_format = int;
alias nk_style_item_type = int;
alias nk_style_header_align = int;
alias nk_panel_type = int;
alias nk_panel_set = int;
alias nk_panel_row_layout_type = int;
alias nk_window_flags = int;

struct nk_style_slide;

enum
{
	nk_false,
	nk_true
}

enum
{
	NK_UP,
	NK_RIGHT,
	NK_DOWN,
	NK_LEFT
}

enum
{
	NK_BUTTON_DEFAULT,
	NK_BUTTON_REPEATER
}

enum
{
	NK_FIXED = nk_false,
	NK_MODIFIABLE = nk_true
}

enum
{
	NK_VERTICAL,
	NK_HORIZONTAL
}

enum
{
	NK_MINIMIZED = nk_false,
	NK_MAXIMIZED = nk_true
}

enum
{
	NK_HIDDEN = nk_false,
	NK_SHOWN = nk_true
}

enum
{
	NK_CHART_LINES,
	NK_CHART_COLUMN,
	NK_CHART_MAX
}

enum
{
	NK_CHART_HOVERING = 0x01,
	NK_CHART_CLICKED = 0x02
}

enum
{
	NK_RGB,
	NK_RGBA
}

enum
{
	NK_POPUP_STATIC,
	NK_POPUP_DYNAMIC
}

enum
{
	NK_DYNAMIC,
	NK_STATIC
}

enum
{
	NK_TREE_NODE,
	NK_TREE_TAB
}

enum
{
	NK_SYMBOL_NONE,
	NK_SYMBOL_X,
	NK_SYMBOL_UNDERSCORE,
	NK_SYMBOL_CIRCLE_SOLID,
	NK_SYMBOL_CIRCLE_OUTLINE,
	NK_SYMBOL_RECT_SOLID,
	NK_SYMBOL_RECT_OUTLINE,
	NK_SYMBOL_TRIANGLE_UP,
	NK_SYMBOL_TRIANGLE_DOWN,
	NK_SYMBOL_TRIANGLE_LEFT,
	NK_SYMBOL_TRIANGLE_RIGHT,
	NK_SYMBOL_PLUS,
	NK_SYMBOL_MINUS,
	NK_SYMBOL_MAX
}

enum
{
	NK_KEY_NONE,
	NK_KEY_SHIFT,
	NK_KEY_CTRL,
	NK_KEY_DEL,
	NK_KEY_ENTER,
	NK_KEY_TAB,
	NK_KEY_BACKSPACE,
	NK_KEY_COPY,
	NK_KEY_CUT,
	NK_KEY_PASTE,
	NK_KEY_UP,
	NK_KEY_DOWN,
	NK_KEY_LEFT,
	NK_KEY_RIGHT,
	NK_KEY_TEXT_INSERT_MODE,
	NK_KEY_TEXT_REPLACE_MODE,
	NK_KEY_TEXT_RESET_MODE,
	NK_KEY_TEXT_LINE_START,
	NK_KEY_TEXT_LINE_END,
	NK_KEY_TEXT_START,
	NK_KEY_TEXT_END,
	NK_KEY_TEXT_UNDO,
	NK_KEY_TEXT_REDO,
	NK_KEY_TEXT_SELECT_ALL,
	NK_KEY_TEXT_WORD_LEFT,
	NK_KEY_TEXT_WORD_RIGHT,
	NK_KEY_SCROLL_START,
	NK_KEY_SCROLL_END,
	NK_KEY_SCROLL_DOWN,
	NK_KEY_SCROLL_UP,
	NK_KEY_MAX
}

enum
{
	NK_BUTTON_LEFT,
	NK_BUTTON_MIDDLE,
	NK_BUTTON_RIGHT,
	NK_BUTTON_DOUBLE,
	NK_BUTTON_MAX
}

enum
{
	NK_ANTI_ALIASING_OFF,
	NK_ANTI_ALIASING_ON
}

enum
{
	NK_CONVERT_SUCCESS = 0,
	NK_CONVERT_INVALID_PARAM = 1,
	NK_CONVERT_COMMAND_BUFFER_FULL = (1<<(1)),
	NK_CONVERT_VERTEX_BUFFER_FULL = (1<<(2)),
	NK_CONVERT_ELEMENT_BUFFER_FULL = (1<<(3))
}

enum
{
	NK_WINDOW_BORDER = (1<<(0)),
	NK_WINDOW_MOVABLE = (1<<(1)),
	NK_WINDOW_SCALABLE = (1<<(2)),
	NK_WINDOW_CLOSABLE = (1<<(3)),
	NK_WINDOW_MINIMIZABLE = (1<<(4)),
	NK_WINDOW_NO_SCROLLBAR = (1<<(5)),
	NK_WINDOW_TITLE = (1<<(6)),
	NK_WINDOW_SCROLL_AUTO_HIDE = (1<<(7)),
	NK_WINDOW_BACKGROUND = (1<<(8)),
	NK_WINDOW_SCALE_LEFT = (1<<(9)),
	NK_WINDOW_NO_INPUT = (1<<(10))
}

enum
{
	NK_WIDGET_INVALID,
	NK_WIDGET_VALID,
	NK_WIDGET_ROM
}

enum
{
	NK_WIDGET_STATE_MODIFIED = (1<<(1)),
	NK_WIDGET_STATE_INACTIVE = (1<<(2)),
	NK_WIDGET_STATE_ENTERED = (1<<(3)),
	NK_WIDGET_STATE_HOVER = (1<<(4)),
	NK_WIDGET_STATE_ACTIVED = (1<<(5)),
	NK_WIDGET_STATE_LEFT = (1<<(6)),
	NK_WIDGET_STATE_HOVERED = NK_WIDGET_STATE_HOVER|NK_WIDGET_STATE_MODIFIED,
	NK_WIDGET_STATE_ACTIVE = NK_WIDGET_STATE_ACTIVED|NK_WIDGET_STATE_MODIFIED
}

enum
{
	NK_TEXT_ALIGN_LEFT = 0x01,
	NK_TEXT_ALIGN_CENTERED = 0x02,
	NK_TEXT_ALIGN_RIGHT = 0x04,
	NK_TEXT_ALIGN_TOP = 0x08,
	NK_TEXT_ALIGN_MIDDLE = 0x10,
	NK_TEXT_ALIGN_BOTTOM = 0x20
}

enum
{
	NK_TEXT_LEFT = NK_TEXT_ALIGN_MIDDLE|NK_TEXT_ALIGN_LEFT,
	NK_TEXT_CENTERED = NK_TEXT_ALIGN_MIDDLE|NK_TEXT_ALIGN_CENTERED,
	NK_TEXT_RIGHT = NK_TEXT_ALIGN_MIDDLE|NK_TEXT_ALIGN_RIGHT
}

enum
{
	NK_EDIT_DEFAULT = 0,
	NK_EDIT_READ_ONLY = (1<<(0)),
	NK_EDIT_AUTO_SELECT = (1<<(1)),
	NK_EDIT_SIG_ENTER = (1<<(2)),
	NK_EDIT_ALLOW_TAB = (1<<(3)),
	NK_EDIT_NO_CURSOR = (1<<(4)),
	NK_EDIT_SELECTABLE = (1<<(5)),
	NK_EDIT_CLIPBOARD = (1<<(6)),
	NK_EDIT_CTRL_ENTER_NEWLINE = (1<<(7)),
	NK_EDIT_NO_HORIZONTAL_SCROLL = (1<<(8)),
	NK_EDIT_ALWAYS_INSERT_MODE = (1<<(9)),
	NK_EDIT_MULTILINE = (1<<(10)),
	NK_EDIT_GOTO_END_ON_ACTIVATE = (1<<(11))
}

enum
{
	NK_EDIT_SIMPLE = NK_EDIT_ALWAYS_INSERT_MODE,
	NK_EDIT_FIELD = NK_EDIT_SIMPLE|NK_EDIT_SELECTABLE|NK_EDIT_CLIPBOARD,
	NK_EDIT_BOX = NK_EDIT_ALWAYS_INSERT_MODE|NK_EDIT_SELECTABLE|NK_EDIT_MULTILINE|NK_EDIT_ALLOW_TAB|NK_EDIT_CLIPBOARD,
	NK_EDIT_EDITOR = NK_EDIT_SELECTABLE|NK_EDIT_MULTILINE|NK_EDIT_ALLOW_TAB|NK_EDIT_CLIPBOARD
}

enum
{
	NK_EDIT_ACTIVE = (1<<(0)),
	NK_EDIT_INACTIVE = (1<<(1)),
	NK_EDIT_ACTIVATED = (1<<(2)),
	NK_EDIT_DEACTIVATED = (1<<(3)),
	NK_EDIT_COMMITED = (1<<(4))
}

enum
{
	NK_COLOR_TEXT,
	NK_COLOR_WINDOW,
	NK_COLOR_HEADER,
	NK_COLOR_BORDER,
	NK_COLOR_BUTTON,
	NK_COLOR_BUTTON_HOVER,
	NK_COLOR_BUTTON_ACTIVE,
	NK_COLOR_TOGGLE,
	NK_COLOR_TOGGLE_HOVER,
	NK_COLOR_TOGGLE_CURSOR,
	NK_COLOR_SELECT,
	NK_COLOR_SELECT_ACTIVE,
	NK_COLOR_SLIDER,
	NK_COLOR_SLIDER_CURSOR,
	NK_COLOR_SLIDER_CURSOR_HOVER,
	NK_COLOR_SLIDER_CURSOR_ACTIVE,
	NK_COLOR_PROPERTY,
	NK_COLOR_EDIT,
	NK_COLOR_EDIT_CURSOR,
	NK_COLOR_COMBO,
	NK_COLOR_CHART,
	NK_COLOR_CHART_COLOR,
	NK_COLOR_CHART_COLOR_HIGHLIGHT,
	NK_COLOR_SCROLLBAR,
	NK_COLOR_SCROLLBAR_CURSOR,
	NK_COLOR_SCROLLBAR_CURSOR_HOVER,
	NK_COLOR_SCROLLBAR_CURSOR_ACTIVE,
	NK_COLOR_TAB_HEADER,
	NK_COLOR_COUNT
}

enum
{
	NK_CURSOR_ARROW,
	NK_CURSOR_TEXT,
	NK_CURSOR_MOVE,
	NK_CURSOR_RESIZE_VERTICAL,
	NK_CURSOR_RESIZE_HORIZONTAL,
	NK_CURSOR_RESIZE_TOP_LEFT_DOWN_RIGHT,
	NK_CURSOR_RESIZE_TOP_RIGHT_DOWN_LEFT,
	NK_CURSOR_COUNT
}

enum
{
	NK_COORD_UV,
	NK_COORD_PIXEL
}

enum
{
	NK_FONT_ATLAS_ALPHA8,
	NK_FONT_ATLAS_RGBA32
}

enum
{
	NK_BUFFER_FIXED,
	NK_BUFFER_DYNAMIC
}

enum
{
	NK_BUFFER_FRONT,
	NK_BUFFER_BACK,
	NK_BUFFER_MAX
}

enum
{
	NK_TEXT_EDIT_SINGLE_LINE,
	NK_TEXT_EDIT_MULTI_LINE
}

enum
{
	NK_TEXT_EDIT_MODE_VIEW,
	NK_TEXT_EDIT_MODE_INSERT,
	NK_TEXT_EDIT_MODE_REPLACE
}

enum
{
	NK_COMMAND_NOP,
	NK_COMMAND_SCISSOR,
	NK_COMMAND_LINE,
	NK_COMMAND_CURVE,
	NK_COMMAND_RECT,
	NK_COMMAND_RECT_FILLED,
	NK_COMMAND_RECT_MULTI_COLOR,
	NK_COMMAND_CIRCLE,
	NK_COMMAND_CIRCLE_FILLED,
	NK_COMMAND_ARC,
	NK_COMMAND_ARC_FILLED,
	NK_COMMAND_TRIANGLE,
	NK_COMMAND_TRIANGLE_FILLED,
	NK_COMMAND_POLYGON,
	NK_COMMAND_POLYGON_FILLED,
	NK_COMMAND_POLYLINE,
	NK_COMMAND_TEXT,
	NK_COMMAND_IMAGE,
	NK_COMMAND_CUSTOM
}

enum
{
	NK_CLIPPING_OFF = nk_false,
	NK_CLIPPING_ON = nk_true
}

enum
{
	NK_STROKE_OPEN = nk_false,
	NK_STROKE_CLOSED = nk_true
}

enum
{
	NK_VERTEX_POSITION,
	NK_VERTEX_COLOR,
	NK_VERTEX_TEXCOORD,
	NK_VERTEX_ATTRIBUTE_COUNT
}

enum
{
	NK_FORMAT_SCHAR,
	NK_FORMAT_SSHORT,
	NK_FORMAT_SINT,
	NK_FORMAT_UCHAR,
	NK_FORMAT_USHORT,
	NK_FORMAT_UINT,
	NK_FORMAT_FLOAT,
	NK_FORMAT_DOUBLE,
	NK_FORMAT_COLOR_BEGIN,
	NK_FORMAT_R8G8B8 = NK_FORMAT_COLOR_BEGIN,
	NK_FORMAT_R16G15B16,
	NK_FORMAT_R32G32B32,
	NK_FORMAT_R8G8B8A8,
	NK_FORMAT_B8G8R8A8,
	NK_FORMAT_R16G15B16A16,
	NK_FORMAT_R32G32B32A32,
	NK_FORMAT_R32G32B32A32_FLOAT,
	NK_FORMAT_R32G32B32A32_DOUBLE,
	NK_FORMAT_RGB32,
	NK_FORMAT_RGBA32,
	NK_FORMAT_COLOR_END = NK_FORMAT_RGBA32,
	NK_FORMAT_COUNT
}

enum
{
	NK_STYLE_ITEM_COLOR,
	NK_STYLE_ITEM_IMAGE
}

enum
{
	NK_HEADER_LEFT,
	NK_HEADER_RIGHT
}

enum
{
	NK_PANEL_NONE = 0,
	NK_PANEL_WINDOW = (1<<(0)),
	NK_PANEL_GROUP = (1<<(1)),
	NK_PANEL_POPUP = (1<<(2)),
	NK_PANEL_CONTEXTUAL = (1<<(4)),
	NK_PANEL_COMBO = (1<<(5)),
	NK_PANEL_MENU = (1<<(6)),
	NK_PANEL_TOOLTIP = (1<<(7))
}

enum
{
	NK_PANEL_SET_NONBLOCK = NK_PANEL_CONTEXTUAL|NK_PANEL_COMBO|NK_PANEL_MENU|NK_PANEL_TOOLTIP,
	NK_PANEL_SET_POPUP = NK_PANEL_SET_NONBLOCK|NK_PANEL_POPUP,
	NK_PANEL_SET_SUB = NK_PANEL_SET_POPUP|NK_PANEL_GROUP
}

enum
{
	NK_LAYOUT_DYNAMIC_FIXED = 0,
	NK_LAYOUT_DYNAMIC_ROW,
	NK_LAYOUT_DYNAMIC_FREE,
	NK_LAYOUT_DYNAMIC,
	NK_LAYOUT_STATIC_FIXED,
	NK_LAYOUT_STATIC_ROW,
	NK_LAYOUT_STATIC_FREE,
	NK_LAYOUT_STATIC,
	NK_LAYOUT_TEMPLATE,
	NK_LAYOUT_COUNT
}

enum
{
	NK_WINDOW_PRIVATE = (1<<(11)),
	NK_WINDOW_DYNAMIC = NK_WINDOW_PRIVATE,
	NK_WINDOW_ROM = (1<<(12)),
	NK_WINDOW_NOT_INTERACTIVE = NK_WINDOW_ROM|NK_WINDOW_NO_INPUT,
	NK_WINDOW_HIDDEN = (1<<(13)),
	NK_WINDOW_CLOSED = (1<<(14)),
	NK_WINDOW_MINIMIZED = (1<<(15)),
	NK_WINDOW_REMOVE_ROM = (1<<(16))
}

union nk_handle
{
	void* ptr;
	int id;
}

union nk_style_item_data
{
	nk_image image;
	nk_color color;
}

union nk_page_data
{
	nk_table tbl;
	nk_panel pan;
	nk_window win;
}

struct nk_color
{
	nk_byte r;
	nk_byte g;
	nk_byte b;
	nk_byte a;
}

struct nk_colorf
{
	float r;
	float g;
	float b;
	float a;
}

struct nk_vec2
{
	float x;
	float y;
}

struct nk_vec2i
{
	short x;
	short y;
}

struct nk_rect
{
	float x;
	float y;
	float w;
	float h;
}

struct nk_recti
{
	short x;
	short y;
	short w;
	short h;
}

struct nk_image
{
	nk_handle handle;
	ushort w;
	ushort h;
	ushort[4] region;
}

struct nk_cursor
{
	nk_image img;
	nk_vec2 size;
	nk_vec2 offset;
}

struct nk_scroll
{
	nk_uint x;
	nk_uint y;
}

struct nk_allocator
{
	nk_handle userdata;
	nk_plugin_alloc alloc;
	nk_plugin_free free;
}

struct nk_draw_null_texture
{
	nk_handle texture;
	nk_vec2 uv;
}

struct nk_convert_config
{
	float global_alpha;
	nk_anti_aliasing line_AA;
	nk_anti_aliasing shape_AA;
	uint circle_segment_count;
	uint arc_segment_count;
	uint curve_segment_count;
	nk_draw_null_texture null_;
	const(nk_draw_vertex_layout_element)* vertex_layout;
	nk_size vertex_size;
	nk_size vertex_alignment;
}

struct nk_list_view
{
	int begin;
	int end;
	int count;
	int total_height;
	nk_context* ctx;
	nk_uint* scroll_pointer;
	nk_uint scroll_value;
}

struct nk_user_font_glyph
{
	nk_vec2[2] uv;
	nk_vec2 offset;
	float width;
	float height;
	float xadvance;
}

struct nk_user_font
{
	nk_handle userdata;
	float height;
	nk_text_width_f width;
	nk_query_font_glyph_f query;
	nk_handle texture;
}

struct nk_baked_font
{
	float height;
	float ascent;
	float descent;
	nk_rune glyph_offset;
	nk_rune glyph_count;
	const(nk_rune)* ranges;
}

struct nk_font_config
{
	nk_font_config* next;
	void* ttf_blob;
	nk_size ttf_size;
	ubyte ttf_data_owned_by_atlas;
	ubyte merge_mode;
	ubyte pixel_snap;
	ubyte oversample_v;
	ubyte oversample_h;
	ubyte[3] padding;
	float size;
	nk_font_coord_type coord_type;
	nk_vec2 spacing;
	const(nk_rune)* range;
	nk_baked_font* font;
	nk_rune fallback_glyph;
	nk_font_config* n;
	nk_font_config* p;
}

struct nk_font_glyph
{
	nk_rune codepoint;
	float xadvance;
	float x0;
	float y0;
	float x1;
	float y1;
	float w;
	float h;
	float u0;
	float v0;
	float u1;
	float v1;
}

struct nk_font
{
	nk_font* next;
	nk_user_font handle;
	nk_baked_font info;
	float scale;
	nk_font_glyph* glyphs;
	const(nk_font_glyph)* fallback;
	nk_rune fallback_codepoint;
	nk_handle texture;
	nk_font_config* config;
}

struct nk_font_atlas
{
	void* pixel;
	int tex_width;
	int tex_height;
	nk_allocator permanent;
	nk_allocator temporary;
	nk_recti custom;
	nk_cursor[NK_CURSOR_COUNT] cursors;
	int glyph_count;
	nk_font_glyph* glyphs;
	nk_font* default_font;
	nk_font* fonts;
	nk_font_config* config;
	int font_num;
}

struct nk_memory_status
{
	void* memory;
	uint type;
	nk_size size;
	nk_size allocated;
	nk_size needed;
	nk_size calls;
}

struct nk_buffer_marker
{
	int active;
	nk_size offset;
}

struct nk_memory
{
	void* ptr;
	nk_size size;
}

struct nk_buffer
{
	nk_buffer_marker[NK_BUFFER_MAX] marker;
	nk_allocator pool;
	nk_allocation_type type;
	nk_memory memory;
	float grow_factor;
	nk_size allocated;
	nk_size needed;
	nk_size calls;
	nk_size size;
}

struct nk_str
{
	nk_buffer buffer;
	int len;
}

struct nk_clipboard
{
	nk_handle userdata;
	nk_plugin_paste paste;
	nk_plugin_copy copy;
}

struct nk_text_undo_record
{
	int where;
	short insert_length;
	short delete_length;
	short char_storage;
}

struct nk_text_undo_state
{
	nk_text_undo_record[99] undo_rec;
	nk_rune[999] undo_char;
	short undo_point;
	short redo_point;
	short undo_char_point;
	short redo_char_point;
}

struct nk_text_edit
{
	nk_clipboard clip;
	nk_str string;
	nk_plugin_filter filter;
	nk_vec2 scrollbar;
	int cursor;
	int select_start;
	int select_end;
	ubyte mode;
	ubyte cursor_at_end_of_line;
	ubyte initialized;
	ubyte has_preferred_x;
	ubyte single_line;
	ubyte active;
	ubyte padding1;
	float preferred_x;
	nk_text_undo_state undo;
}

struct nk_command
{
	nk_command_type type;
	nk_size next;
}

struct nk_command_scissor
{
	nk_command header;
	short x;
	short y;
	ushort w;
	ushort h;
}

struct nk_command_line
{
	nk_command header;
	ushort line_thickness;
	nk_vec2i begin;
	nk_vec2i end;
	nk_color color;
}

struct nk_command_curve
{
	nk_command header;
	ushort line_thickness;
	nk_vec2i begin;
	nk_vec2i end;
	nk_vec2i[2] ctrl;
	nk_color color;
}

struct nk_command_rect
{
	nk_command header;
	ushort rounding;
	ushort line_thickness;
	short x;
	short y;
	ushort w;
	ushort h;
	nk_color color;
}

struct nk_command_rect_filled
{
	nk_command header;
	ushort rounding;
	short x;
	short y;
	ushort w;
	ushort h;
	nk_color color;
}

struct nk_command_rect_multi_color
{
	nk_command header;
	short x;
	short y;
	ushort w;
	ushort h;
	nk_color left;
	nk_color top;
	nk_color bottom;
	nk_color right;
}

struct nk_command_triangle
{
	nk_command header;
	ushort line_thickness;
	nk_vec2i a;
	nk_vec2i b;
	nk_vec2i c;
	nk_color color;
}

struct nk_command_triangle_filled
{
	nk_command header;
	nk_vec2i a;
	nk_vec2i b;
	nk_vec2i c;
	nk_color color;
}

struct nk_command_circle
{
	nk_command header;
	short x;
	short y;
	ushort line_thickness;
	ushort w;
	ushort h;
	nk_color color;
}

struct nk_command_circle_filled
{
	nk_command header;
	short x;
	short y;
	ushort w;
	ushort h;
	nk_color color;
}

struct nk_command_arc
{
	nk_command header;
	short cx;
	short cy;
	ushort r;
	ushort line_thickness;
	float[2] a;
	nk_color color;
}

struct nk_command_arc_filled
{
	nk_command header;
	short cx;
	short cy;
	ushort r;
	float[2] a;
	nk_color color;
}

struct nk_command_polygon
{
	nk_command header;
	nk_color color;
	ushort line_thickness;
	ushort point_count;
	nk_vec2i[1] points;
}

struct nk_command_polygon_filled
{
	nk_command header;
	nk_color color;
	ushort point_count;
	nk_vec2i[1] points;
}

struct nk_command_polyline
{
	nk_command header;
	nk_color color;
	ushort line_thickness;
	ushort point_count;
	nk_vec2i[1] points;
}

struct nk_command_image
{
	nk_command header;
	short x;
	short y;
	ushort w;
	ushort h;
	nk_image img;
	nk_color col;
}

struct nk_command_custom
{
	nk_command header;
	short x;
	short y;
	ushort w;
	ushort h;
	nk_handle callback_data;
	nk_command_custom_callback callback;
}

struct nk_command_text
{
	nk_command header;
	const(nk_user_font)* font;
	nk_color background;
	nk_color foreground;
	short x;
	short y;
	ushort w;
	ushort h;
	float height;
	int length;
	char[1] string;
}

struct nk_command_buffer
{
	nk_buffer* base;
	nk_rect clip;
	int use_clipping;
	nk_handle userdata;
	nk_size begin;
	nk_size end;
	nk_size last;
}

struct nk_mouse_button
{
	int down;
	uint clicked;
	nk_vec2 clicked_pos;
}

struct nk_mouse
{
	nk_mouse_button[NK_BUTTON_MAX] buttons;
	nk_vec2 pos;
	nk_vec2 prev;
	nk_vec2 delta;
	nk_vec2 scroll_delta;
	ubyte grab;
	ubyte grabbed;
	ubyte ungrab;
}

struct nk_key
{
	int down;
	uint clicked;
}

struct nk_keyboard
{
	nk_key[NK_KEY_MAX] keys;
	char[16] text;
	int text_len;
}

struct nk_input
{
	nk_keyboard keyboard;
	nk_mouse mouse;
}

struct nk_draw_vertex_layout_element
{
	nk_draw_vertex_layout_attribute attribute;
	nk_draw_vertex_layout_format format;
	nk_size offset;
}

struct nk_draw_command
{
	uint elem_count;
	nk_rect clip_rect;
	nk_handle texture;
}

struct nk_draw_list
{
	nk_rect clip_rect;
	nk_vec2[12] circle_vtx;
	nk_convert_config config;
	nk_buffer* buffer;
	nk_buffer* vertices;
	nk_buffer* elements;
	uint element_count;
	uint vertex_count;
	uint cmd_count;
	nk_size cmd_offset;
	uint path_count;
	uint path_offset;
	nk_anti_aliasing line_AA;
	nk_anti_aliasing shape_AA;
}

struct nk_style_item
{
	nk_style_item_type type;
	nk_style_item_data data;
}

struct nk_style_text
{
	nk_color color;
	nk_vec2 padding;
}

struct nk_style_button
{
	nk_style_item normal;
	nk_style_item hover;
	nk_style_item active;
	nk_color border_color;
	nk_color text_background;
	nk_color text_normal;
	nk_color text_hover;
	nk_color text_active;
	nk_flags text_alignment;
	float border;
	float rounding;
	nk_vec2 padding;
	nk_vec2 image_padding;
	nk_vec2 touch_padding;
	nk_handle userdata;
	void function(nk_command_buffer*, nk_handle userdata) draw_begin;
	void function(nk_command_buffer*, nk_handle userdata) draw_end;
}

struct nk_style_toggle
{
	nk_style_item normal;
	nk_style_item hover;
	nk_style_item active;
	nk_color border_color;
	nk_style_item cursor_normal;
	nk_style_item cursor_hover;
	nk_color text_normal;
	nk_color text_hover;
	nk_color text_active;
	nk_color text_background;
	nk_flags text_alignment;
	nk_vec2 padding;
	nk_vec2 touch_padding;
	float spacing;
	float border;
	nk_handle userdata;
	void function(nk_command_buffer*, nk_handle) draw_begin;
	void function(nk_command_buffer*, nk_handle) draw_end;
}

struct nk_style_selectable
{
	nk_style_item normal;
	nk_style_item hover;
	nk_style_item pressed;
	nk_style_item normal_active;
	nk_style_item hover_active;
	nk_style_item pressed_active;
	nk_color text_normal;
	nk_color text_hover;
	nk_color text_pressed;
	nk_color text_normal_active;
	nk_color text_hover_active;
	nk_color text_pressed_active;
	nk_color text_background;
	nk_flags text_alignment;
	float rounding;
	nk_vec2 padding;
	nk_vec2 touch_padding;
	nk_vec2 image_padding;
	nk_handle userdata;
	void function(nk_command_buffer*, nk_handle) draw_begin;
	void function(nk_command_buffer*, nk_handle) draw_end;
}

struct nk_style_slider
{
	nk_style_item normal;
	nk_style_item hover;
	nk_style_item active;
	nk_color border_color;
	nk_color bar_normal;
	nk_color bar_hover;
	nk_color bar_active;
	nk_color bar_filled;
	nk_style_item cursor_normal;
	nk_style_item cursor_hover;
	nk_style_item cursor_active;
	float border;
	float rounding;
	float bar_height;
	nk_vec2 padding;
	nk_vec2 spacing;
	nk_vec2 cursor_size;
	int show_buttons;
	nk_style_button inc_button;
	nk_style_button dec_button;
	nk_symbol_type inc_symbol;
	nk_symbol_type dec_symbol;
	nk_handle userdata;
	void function(nk_command_buffer*, nk_handle) draw_begin;
	void function(nk_command_buffer*, nk_handle) draw_end;
}

struct nk_style_progress
{
	nk_style_item normal;
	nk_style_item hover;
	nk_style_item active;
	nk_color border_color;
	nk_style_item cursor_normal;
	nk_style_item cursor_hover;
	nk_style_item cursor_active;
	nk_color cursor_border_color;
	float rounding;
	float border;
	float cursor_border;
	float cursor_rounding;
	nk_vec2 padding;
	nk_handle userdata;
	void function(nk_command_buffer*, nk_handle) draw_begin;
	void function(nk_command_buffer*, nk_handle) draw_end;
}

struct nk_style_scrollbar
{
	nk_style_item normal;
	nk_style_item hover;
	nk_style_item active;
	nk_color border_color;
	nk_style_item cursor_normal;
	nk_style_item cursor_hover;
	nk_style_item cursor_active;
	nk_color cursor_border_color;
	float border;
	float rounding;
	float border_cursor;
	float rounding_cursor;
	nk_vec2 padding;
	int show_buttons;
	nk_style_button inc_button;
	nk_style_button dec_button;
	nk_symbol_type inc_symbol;
	nk_symbol_type dec_symbol;
	nk_handle userdata;
	void function(nk_command_buffer*, nk_handle) draw_begin;
	void function(nk_command_buffer*, nk_handle) draw_end;
}

struct nk_style_edit
{
	nk_style_item normal;
	nk_style_item hover;
	nk_style_item active;
	nk_color border_color;
	nk_style_scrollbar scrollbar;
	nk_color cursor_normal;
	nk_color cursor_hover;
	nk_color cursor_text_normal;
	nk_color cursor_text_hover;
	nk_color text_normal;
	nk_color text_hover;
	nk_color text_active;
	nk_color selected_normal;
	nk_color selected_hover;
	nk_color selected_text_normal;
	nk_color selected_text_hover;
	float border;
	float rounding;
	float cursor_size;
	nk_vec2 scrollbar_size;
	nk_vec2 padding;
	float row_padding;
}

struct nk_style_property
{
	nk_style_item normal;
	nk_style_item hover;
	nk_style_item active;
	nk_color border_color;
	nk_color label_normal;
	nk_color label_hover;
	nk_color label_active;
	nk_symbol_type sym_left;
	nk_symbol_type sym_right;
	float border;
	float rounding;
	nk_vec2 padding;
	nk_style_edit edit;
	nk_style_button inc_button;
	nk_style_button dec_button;
	nk_handle userdata;
	void function(nk_command_buffer*, nk_handle) draw_begin;
	void function(nk_command_buffer*, nk_handle) draw_end;
}

struct nk_style_chart
{
	nk_style_item background;
	nk_color border_color;
	nk_color selected_color;
	nk_color color;
	float border;
	float rounding;
	nk_vec2 padding;
}

struct nk_style_combo
{
	nk_style_item normal;
	nk_style_item hover;
	nk_style_item active;
	nk_color border_color;
	nk_color label_normal;
	nk_color label_hover;
	nk_color label_active;
	nk_color symbol_normal;
	nk_color symbol_hover;
	nk_color symbol_active;
	nk_style_button button;
	nk_symbol_type sym_normal;
	nk_symbol_type sym_hover;
	nk_symbol_type sym_active;
	float border;
	float rounding;
	nk_vec2 content_padding;
	nk_vec2 button_padding;
	nk_vec2 spacing;
}

struct nk_style_tab
{
	nk_style_item background;
	nk_color border_color;
	nk_color text;
	nk_style_button tab_maximize_button;
	nk_style_button tab_minimize_button;
	nk_style_button node_maximize_button;
	nk_style_button node_minimize_button;
	nk_symbol_type sym_minimize;
	nk_symbol_type sym_maximize;
	float border;
	float rounding;
	float indent;
	nk_vec2 padding;
	nk_vec2 spacing;
}

struct nk_style_window_header
{
	nk_style_item normal;
	nk_style_item hover;
	nk_style_item active;
	nk_style_button close_button;
	nk_style_button minimize_button;
	nk_symbol_type close_symbol;
	nk_symbol_type minimize_symbol;
	nk_symbol_type maximize_symbol;
	nk_color label_normal;
	nk_color label_hover;
	nk_color label_active;
	nk_style_header_align align_;
	nk_vec2 padding;
	nk_vec2 label_padding;
	nk_vec2 spacing;
}

struct nk_style_window
{
	nk_style_window_header header;
	nk_style_item fixed_background;
	nk_color background;
	nk_color border_color;
	nk_color popup_border_color;
	nk_color combo_border_color;
	nk_color contextual_border_color;
	nk_color menu_border_color;
	nk_color group_border_color;
	nk_color tooltip_border_color;
	nk_style_item scaler;
	float border;
	float combo_border;
	float contextual_border;
	float menu_border;
	float group_border;
	float tooltip_border;
	float popup_border;
	float min_row_height_padding;
	float rounding;
	nk_vec2 spacing;
	nk_vec2 scrollbar_size;
	nk_vec2 min_size;
	nk_vec2 padding;
	nk_vec2 group_padding;
	nk_vec2 popup_padding;
	nk_vec2 combo_padding;
	nk_vec2 contextual_padding;
	nk_vec2 menu_padding;
	nk_vec2 tooltip_padding;
}

struct nk_style
{
	const(nk_user_font)* font;
	const(nk_cursor)*[NK_CURSOR_COUNT] cursors;
	const(nk_cursor)* cursor_active;
	nk_cursor* cursor_last;
	int cursor_visible;
	nk_style_text text;
	nk_style_button button;
	nk_style_button contextual_button;
	nk_style_button menu_button;
	nk_style_toggle option;
	nk_style_toggle checkbox;
	nk_style_selectable selectable;
	nk_style_slider slider;
	nk_style_progress progress;
	nk_style_property property;
	nk_style_edit edit;
	nk_style_chart chart;
	nk_style_scrollbar scrollh;
	nk_style_scrollbar scrollv;
	nk_style_tab tab;
	nk_style_combo combo;
	nk_style_window window;
}

struct nk_chart_slot
{
	nk_chart_type type;
	nk_color color;
	nk_color highlight;
	float min;
	float max;
	float range;
	int count;
	nk_vec2 last;
	int index;
}

struct nk_chart
{
	int slot;
	float x;
	float y;
	float w;
	float h;
	nk_chart_slot[4] slots;
}

struct nk_row_layout
{
	nk_panel_row_layout_type type;
	int index;
	float height;
	float min_height;
	int columns;
	const(float)* ratio;
	float item_width;
	float item_height;
	float item_offset;
	float filled;
	nk_rect item;
	int tree_depth;
	float[16] templates;
}

struct nk_popup_buffer
{
	nk_size begin;
	nk_size parent;
	nk_size last;
	nk_size end;
	int active;
}

struct nk_menu_state
{
	float x;
	float y;
	float w;
	float h;
	nk_scroll offset;
}

struct nk_panel
{
	nk_panel_type type;
	nk_flags flags;
	nk_rect bounds;
	nk_uint* offset_x;
	nk_uint* offset_y;
	float at_x;
	float at_y;
	float max_x;
	float footer_height;
	float header_height;
	float border;
	uint has_scrolling;
	nk_rect clip;
	nk_menu_state menu;
	nk_row_layout row;
	nk_chart chart;
	nk_command_buffer* buffer;
	nk_panel* parent;
}

struct nk_popup_state
{
	nk_window* win;
	nk_panel_type type;
	nk_popup_buffer buf;
	nk_hash name;
	int active;
	uint combo_count;
	uint con_count;
	uint con_old;
	uint active_con;
	nk_rect header;
}

struct nk_edit_state
{
	nk_hash name;
	uint seq;
	uint old;
	int active;
	int prev;
	int cursor;
	int sel_start;
	int sel_end;
	nk_scroll scrollbar;
	ubyte mode;
	ubyte single_line;
}

struct nk_property_state
{
	int active;
	int prev;
	char[64] buffer;
	int length;
	int cursor;
	int select_start;
	int select_end;
	nk_hash name;
	uint seq;
	uint old;
	int state;
}

struct nk_window
{
	uint seq;
	nk_hash name;
	char[64] name_string;
	nk_flags flags;
	nk_rect bounds;
	nk_scroll scrollbar;
	nk_command_buffer buffer;
	nk_panel* layout;
	float scrollbar_hiding_timer;
	nk_property_state property;
	nk_popup_state popup;
	nk_edit_state edit;
	uint scrolled;
	nk_table* tables;
	uint table_count;
	nk_window* next;
	nk_window* prev;
	nk_window* parent;
}

struct nk_config_stack_style_item_element
{
	nk_style_item* address;
	nk_style_item old_value;
}

struct nk_config_stack_float_element
{
	float* address;
	float old_value;
}

struct nk_config_stack_vec2_element
{
	nk_vec2* address;
	nk_vec2 old_value;
}

struct nk_config_stack_flags_element
{
	nk_flags* address;
	nk_flags old_value;
}

struct nk_config_stack_color_element
{
	nk_color* address;
	nk_color old_value;
}

struct nk_config_stack_user_font_element
{
	const(nk_user_font)** address;
	const(nk_user_font)* old_value;
}

struct nk_config_stack_button_behavior_element
{
	nk_button_behavior* address;
	nk_button_behavior old_value;
}

struct nk_config_stack_style_item
{
	int head;
	nk_config_stack_style_item_element[16] elements;
}

struct nk_config_stack_float
{
	int head;
	nk_config_stack_float_element[32] elements;
}

struct nk_config_stack_vec2
{
	int head;
	nk_config_stack_vec2_element[16] elements;
}

struct nk_config_stack_flags
{
	int head;
	nk_config_stack_flags_element[32] elements;
}

struct nk_config_stack_color
{
	int head;
	nk_config_stack_color_element[32] elements;
}

struct nk_config_stack_user_font
{
	int head;
	nk_config_stack_user_font_element[8] elements;
}

struct nk_config_stack_button_behavior
{
	int head;
	nk_config_stack_button_behavior_element[8] elements;
}

struct nk_configuration_stacks
{
	nk_config_stack_style_item style_items;
	nk_config_stack_float floats;
	nk_config_stack_vec2 vectors;
	nk_config_stack_flags flags;
	nk_config_stack_color colors;
	nk_config_stack_user_font fonts;
	nk_config_stack_button_behavior button_behaviors;
}

import std;
enum NK_VALUE_PAGE_CAPACITY = (max(nk_window.sizeof, nk_panel.sizeof) / nk_uint.sizeof) / 2;

struct nk_table
{
	uint seq;
	uint size;
	nk_hash[NK_VALUE_PAGE_CAPACITY] keys;
	nk_uint[NK_VALUE_PAGE_CAPACITY] values;
	nk_table* next;
	nk_table* prev;
}

struct nk_page_element
{
	nk_page_data data;
	nk_page_element* next;
	nk_page_element* prev;
}

struct nk_page
{
	uint size;
	nk_page* next;
	nk_page_element[1] win;
}

struct nk_pool
{
	nk_allocator alloc;
	nk_allocation_type type;
	uint page_count;
	nk_page* pages;
	nk_page_element* freelist;
	uint capacity;
	nk_size size;
	nk_size cap;
}

struct nk_context
{
	nk_input input;
	nk_style style;
	nk_buffer memory;
	nk_clipboard clip;
	nk_flags last_widget_state;
	nk_button_behavior button_behavior;
	nk_configuration_stacks stacks;
	float delta_time_seconds;
	nk_draw_list draw_list;
	nk_text_edit text_edit;
	nk_command_buffer overlay;
	int build;
	int use_pool;
	nk_pool pool;
	nk_window* begin;
	nk_window* end;
	nk_window* active;
	nk_window* current;
	nk_page_element* freelist;
	uint count;
	uint seq;
}

int nk_init_default(nk_context*, const(nk_user_font)*);
int nk_init_fixed(nk_context*, void* memory, nk_size size, const(nk_user_font)*);
int nk_init(nk_context*, nk_allocator*, const(nk_user_font)*);
int nk_init_custom(nk_context*, nk_buffer* cmds, nk_buffer* pool, const(nk_user_font)*);
void nk_clear(nk_context*);
void nk_free(nk_context*);
void nk_input_begin(nk_context*);
void nk_input_motion(nk_context*, int x, int y);
void nk_input_key(nk_context*, nk_keys, int down);
void nk_input_button(nk_context*, nk_buttons, int x, int y, int down);
void nk_input_scroll(nk_context*, nk_vec2 val);
void nk_input_char(nk_context*, char);
void nk_input_glyph(nk_context*, const(char)*);
void nk_input_unicode(nk_context*, nk_rune);
void nk_input_end(nk_context*);
const(nk_command)* nk__begin(nk_context*);
const(nk_command)* nk__next(nk_context*, const(nk_command)*);
nk_flags nk_convert(nk_context*, nk_buffer* cmds, nk_buffer* vertices, nk_buffer* elements, const(nk_convert_config)*);
const(nk_draw_command)* nk__draw_begin(const(nk_context)*, const(nk_buffer)*);
const(nk_draw_command)* nk__draw_end(const(nk_context)*, const(nk_buffer)*);
const(nk_draw_command)* nk__draw_next(const(nk_draw_command)*, const(nk_buffer)*, const(nk_context)*);
int nk_begin(nk_context* ctx, const(char)* title, nk_rect bounds, nk_flags flags);
int nk_begin_titled(nk_context* ctx, const(char)* name, const(char)* title, nk_rect bounds, nk_flags flags);
void nk_end(nk_context* ctx);
nk_window* nk_window_find(nk_context* ctx, const(char)* name);
nk_rect nk_window_get_bounds(const(nk_context)* ctx);
nk_vec2 nk_window_get_position(const(nk_context)* ctx);
nk_vec2 nk_window_get_size(const(nk_context)*);
float nk_window_get_width(const(nk_context)*);
float nk_window_get_height(const(nk_context)*);
nk_panel* nk_window_get_panel(nk_context*);
nk_rect nk_window_get_content_region(nk_context*);
nk_vec2 nk_window_get_content_region_min(nk_context*);
nk_vec2 nk_window_get_content_region_max(nk_context*);
nk_vec2 nk_window_get_content_region_size(nk_context*);
nk_command_buffer* nk_window_get_canvas(nk_context*);
void nk_window_get_scroll(nk_context*, nk_uint* offset_x, nk_uint* offset_y);
int nk_window_has_focus(const(nk_context)*);
int nk_window_is_hovered(nk_context*);
int nk_window_is_collapsed(nk_context* ctx, const(char)* name);
int nk_window_is_closed(nk_context*, const(char)*);
int nk_window_is_hidden(nk_context*, const(char)*);
int nk_window_is_active(nk_context*, const(char)*);
int nk_window_is_any_hovered(nk_context*);
int nk_item_is_any_active(nk_context*);
void nk_window_set_bounds(nk_context*, const(char)* name, nk_rect bounds);
void nk_window_set_position(nk_context*, const(char)* name, nk_vec2 pos);
void nk_window_set_size(nk_context*, const(char)* name, nk_vec2);
void nk_window_set_focus(nk_context*, const(char)* name);
void nk_window_set_scroll(nk_context*, nk_uint offset_x, nk_uint offset_y);
void nk_window_close(nk_context* ctx, const(char)* name);
void nk_window_collapse(nk_context*, const(char)* name, nk_collapse_states state);
void nk_window_collapse_if(nk_context*, const(char)* name, nk_collapse_states, int cond);
void nk_window_show(nk_context*, const(char)* name, nk_show_states);
void nk_window_show_if(nk_context*, const(char)* name, nk_show_states, int cond);
void nk_layout_set_min_row_height(nk_context*, float height);
void nk_layout_reset_min_row_height(nk_context*);
nk_rect nk_layout_widget_bounds(nk_context*);
float nk_layout_ratio_from_pixel(nk_context*, float pixel_width);
void nk_layout_row_dynamic(nk_context* ctx, float height, int cols);
void nk_layout_row_static(nk_context* ctx, float height, int item_width, int cols);
void nk_layout_row_begin(nk_context* ctx, nk_layout_format fmt, float row_height, int cols);
void nk_layout_row_push(nk_context*, float value);
void nk_layout_row_end(nk_context*);
void nk_layout_row(nk_context*, nk_layout_format, float height, int cols, const(float)* ratio);
void nk_layout_row_template_begin(nk_context*, float row_height);
void nk_layout_row_template_push_dynamic(nk_context*);
void nk_layout_row_template_push_variable(nk_context*, float min_width);
void nk_layout_row_template_push_static(nk_context*, float width);
void nk_layout_row_template_end(nk_context*);
void nk_layout_space_begin(nk_context*, nk_layout_format, float height, int widget_count);
void nk_layout_space_push(nk_context*, nk_rect bounds);
void nk_layout_space_end(nk_context*);
nk_rect nk_layout_space_bounds(nk_context*);
nk_vec2 nk_layout_space_to_screen(nk_context*, nk_vec2);
nk_vec2 nk_layout_space_to_local(nk_context*, nk_vec2);
nk_rect nk_layout_space_rect_to_screen(nk_context*, nk_rect);
nk_rect nk_layout_space_rect_to_local(nk_context*, nk_rect);
int nk_group_begin(nk_context*, const(char)* title, nk_flags);
int nk_group_begin_titled(nk_context*, const(char)* name, const(char)* title, nk_flags);
void nk_group_end(nk_context*);
int nk_group_scrolled_offset_begin(nk_context*, nk_uint* x_offset, nk_uint* y_offset, const(char)* title, nk_flags flags);
int nk_group_scrolled_begin(nk_context*, nk_scroll* off, const(char)* title, nk_flags);
void nk_group_scrolled_end(nk_context*);
void nk_group_get_scroll(nk_context*, const(char)* id, nk_uint* x_offset, nk_uint* y_offset);
void nk_group_set_scroll(nk_context*, const(char)* id, nk_uint x_offset, nk_uint y_offset);
int nk_tree_push_hashed(nk_context*, nk_tree_type, const(char)* title, nk_collapse_states initial_state, const(char)* hash, int len, int seed);
int nk_tree_image_push_hashed(nk_context*, nk_tree_type, nk_image, const(char)* title, nk_collapse_states initial_state, const(char)* hash, int len, int seed);
void nk_tree_pop(nk_context*);
int nk_tree_state_push(nk_context*, nk_tree_type, const(char)* title, nk_collapse_states* state);
int nk_tree_state_image_push(nk_context*, nk_tree_type, nk_image, const(char)* title, nk_collapse_states* state);
void nk_tree_state_pop(nk_context*);
int nk_tree_element_push_hashed(nk_context*, nk_tree_type, const(char)* title, nk_collapse_states initial_state, int* selected, const(char)* hash, int len, int seed);
int nk_tree_element_image_push_hashed(nk_context*, nk_tree_type, nk_image, const(char)* title, nk_collapse_states initial_state, int* selected, const(char)* hash, int len, int seed);
void nk_tree_element_pop(nk_context*);
int nk_list_view_begin(nk_context*, nk_list_view* out_, const(char)* id, nk_flags, int row_height, int row_count);
void nk_list_view_end(nk_list_view*);
nk_widget_layout_states nk_widget(nk_rect*, const(nk_context)*);
nk_widget_layout_states nk_widget_fitting(nk_rect*, nk_context*, nk_vec2);
nk_rect nk_widget_bounds(nk_context*);
nk_vec2 nk_widget_position(nk_context*);
nk_vec2 nk_widget_size(nk_context*);
float nk_widget_width(nk_context*);
float nk_widget_height(nk_context*);
int nk_widget_is_hovered(nk_context*);
int nk_widget_is_mouse_clicked(nk_context*, nk_buttons);
int nk_widget_has_mouse_click_down(nk_context*, nk_buttons, int down);
void nk_spacing(nk_context*, int cols);
void nk_text(nk_context*, const(char)*, int, nk_flags);
void nk_text_colored(nk_context*, const(char)*, int, nk_flags, nk_color);
void nk_text_wrap(nk_context*, const(char)*, int);
void nk_text_wrap_colored(nk_context*, const(char)*, int, nk_color);
void nk_label(nk_context*, const(char)*, nk_flags align_);
void nk_label_colored(nk_context*, const(char)*, nk_flags align_, nk_color);
void nk_label_wrap(nk_context*, const(char)*);
void nk_label_colored_wrap(nk_context*, const(char)*, nk_color);
pragma(mangle, `nk_image`) void nk_image_(nk_context*, nk_image);
void nk_image_color(nk_context*, nk_image, nk_color);
void nk_labelf(nk_context*, nk_flags, const(char)*, ...);
void nk_labelf_colored(nk_context*, nk_flags, nk_color, const(char)*, ...);
void nk_labelf_wrap(nk_context*, const(char)*, ...);
void nk_labelf_colored_wrap(nk_context*, nk_color, const(char)*, ...);
void nk_labelfv(nk_context*, nk_flags, const(char)*, va_list);
void nk_labelfv_colored(nk_context*, nk_flags, nk_color, const(char)*, va_list);
void nk_labelfv_wrap(nk_context*, const(char)*, va_list);
void nk_labelfv_colored_wrap(nk_context*, nk_color, const(char)*, va_list);
void nk_value_bool(nk_context*, const(char)* prefix, int);
void nk_value_int(nk_context*, const(char)* prefix, int);
void nk_value_uint(nk_context*, const(char)* prefix, uint);
void nk_value_float(nk_context*, const(char)* prefix, float);
void nk_value_color_byte(nk_context*, const(char)* prefix, nk_color);
void nk_value_color_float(nk_context*, const(char)* prefix, nk_color);
void nk_value_color_hex(nk_context*, const(char)* prefix, nk_color);
int nk_button_text(nk_context*, const(char)* title, int len);
int nk_button_label(nk_context*, const(char)* title);
int nk_button_color(nk_context*, nk_color);
int nk_button_symbol(nk_context*, nk_symbol_type);
int nk_button_image(nk_context*, nk_image img);
int nk_button_symbol_label(nk_context*, nk_symbol_type, const(char)*, nk_flags text_alignment);
int nk_button_symbol_text(nk_context*, nk_symbol_type, const(char)*, int, nk_flags alignment);
int nk_button_image_label(nk_context*, nk_image img, const(char)*, nk_flags text_alignment);
int nk_button_image_text(nk_context*, nk_image img, const(char)*, int, nk_flags alignment);
int nk_button_text_styled(nk_context*, const(nk_style_button)*, const(char)* title, int len);
int nk_button_label_styled(nk_context*, const(nk_style_button)*, const(char)* title);
int nk_button_symbol_styled(nk_context*, const(nk_style_button)*, nk_symbol_type);
int nk_button_image_styled(nk_context*, const(nk_style_button)*, nk_image img);
int nk_button_symbol_text_styled(nk_context*, const(nk_style_button)*, nk_symbol_type, const(char)*, int, nk_flags alignment);
int nk_button_symbol_label_styled(nk_context* ctx, const(nk_style_button)* style, nk_symbol_type symbol, const(char)* title, nk_flags align_);
int nk_button_image_label_styled(nk_context*, const(nk_style_button)*, nk_image img, const(char)*, nk_flags text_alignment);
int nk_button_image_text_styled(nk_context*, const(nk_style_button)*, nk_image img, const(char)*, int, nk_flags alignment);
void nk_button_set_behavior(nk_context*, nk_button_behavior);
int nk_button_push_behavior(nk_context*, nk_button_behavior);
int nk_button_pop_behavior(nk_context*);
int nk_check_label(nk_context*, const(char)*, int active);
int nk_check_text(nk_context*, const(char)*, int, int active);
uint nk_check_flags_label(nk_context*, const(char)*, uint flags, uint value);
uint nk_check_flags_text(nk_context*, const(char)*, int, uint flags, uint value);
int nk_checkbox_label(nk_context*, const(char)*, int* active);
int nk_checkbox_text(nk_context*, const(char)*, int, int* active);
int nk_checkbox_flags_label(nk_context*, const(char)*, uint* flags, uint value);
int nk_checkbox_flags_text(nk_context*, const(char)*, int, uint* flags, uint value);
int nk_radio_label(nk_context*, const(char)*, int* active);
int nk_radio_text(nk_context*, const(char)*, int, int* active);
int nk_option_label(nk_context*, const(char)*, int active);
int nk_option_text(nk_context*, const(char)*, int, int active);
int nk_selectable_label(nk_context*, const(char)*, nk_flags align_, int* value);
int nk_selectable_text(nk_context*, const(char)*, int, nk_flags align_, int* value);
int nk_selectable_image_label(nk_context*, nk_image, const(char)*, nk_flags align_, int* value);
int nk_selectable_image_text(nk_context*, nk_image, const(char)*, int, nk_flags align_, int* value);
int nk_selectable_symbol_label(nk_context*, nk_symbol_type, const(char)*, nk_flags align_, int* value);
int nk_selectable_symbol_text(nk_context*, nk_symbol_type, const(char)*, int, nk_flags align_, int* value);
int nk_select_label(nk_context*, const(char)*, nk_flags align_, int value);
int nk_select_text(nk_context*, const(char)*, int, nk_flags align_, int value);
int nk_select_image_label(nk_context*, nk_image, const(char)*, nk_flags align_, int value);
int nk_select_image_text(nk_context*, nk_image, const(char)*, int, nk_flags align_, int value);
int nk_select_symbol_label(nk_context*, nk_symbol_type, const(char)*, nk_flags align_, int value);
int nk_select_symbol_text(nk_context*, nk_symbol_type, const(char)*, int, nk_flags align_, int value);
float nk_slide_float(nk_context*, float min, float val, float max, float step);
int nk_slide_int(nk_context*, int min, int val, int max, int step);
int nk_slider_float(nk_context*, float min, float* val, float max, float step);
int nk_slider_int(nk_context*, int min, int* val, int max, int step);
int nk_progress(nk_context*, nk_size* cur, nk_size max, int modifyable);
nk_size nk_prog(nk_context*, nk_size cur, nk_size max, int modifyable);
nk_colorf nk_color_picker(nk_context*, nk_colorf, nk_color_format);
int nk_color_pick(nk_context*, nk_colorf*, nk_color_format);
void nk_property_int(nk_context*, const(char)* name, int min, int* val, int max, int step, float inc_per_pixel);
void nk_property_float(nk_context*, const(char)* name, float min, float* val, float max, float step, float inc_per_pixel);
void nk_property_double(nk_context*, const(char)* name, double min, double* val, double max, double step, float inc_per_pixel);
int nk_propertyi(nk_context*, const(char)* name, int min, int val, int max, int step, float inc_per_pixel);
float nk_propertyf(nk_context*, const(char)* name, float min, float val, float max, float step, float inc_per_pixel);
double nk_propertyd(nk_context*, const(char)* name, double min, double val, double max, double step, float inc_per_pixel);
nk_flags nk_edit_string(nk_context*, nk_flags, char* buffer, int* len, int max, nk_plugin_filter);
nk_flags nk_edit_string_zero_terminated(nk_context*, nk_flags, char* buffer, int max, nk_plugin_filter);
nk_flags nk_edit_buffer(nk_context*, nk_flags, nk_text_edit*, nk_plugin_filter);
void nk_edit_focus(nk_context*, nk_flags flags);
void nk_edit_unfocus(nk_context*);
int nk_chart_begin(nk_context*, nk_chart_type, int num, float min, float max);
int nk_chart_begin_colored(nk_context*, nk_chart_type, nk_color, nk_color active, int num, float min, float max);
void nk_chart_add_slot(nk_context* ctx, const(nk_chart_type), int count, float min_value, float max_value);
void nk_chart_add_slot_colored(nk_context* ctx, const(nk_chart_type), nk_color, nk_color active, int count, float min_value, float max_value);
nk_flags nk_chart_push(nk_context*, float);
nk_flags nk_chart_push_slot(nk_context*, float, int);
void nk_chart_end(nk_context*);
void nk_plot(nk_context*, nk_chart_type, const(float)* values, int count, int offset);
void nk_plot_function(nk_context*, nk_chart_type, void* userdata, float function(void* user, int index) value_getter, int count, int offset);
int nk_popup_begin(nk_context*, nk_popup_type, const(char)*, nk_flags, nk_rect bounds);
void nk_popup_close(nk_context*);
void nk_popup_end(nk_context*);
void nk_popup_get_scroll(nk_context*, nk_uint* offset_x, nk_uint* offset_y);
void nk_popup_set_scroll(nk_context*, nk_uint offset_x, nk_uint offset_y);
int nk_combo(nk_context*, const(char)** items, int count, int selected, int item_height, nk_vec2 size);
int nk_combo_separator(nk_context*, const(char)* items_separated_by_separator, int separator, int selected, int count, int item_height, nk_vec2 size);
int nk_combo_string(nk_context*, const(char)* items_separated_by_zeros, int selected, int count, int item_height, nk_vec2 size);
int nk_combo_callback(nk_context*, void function(void*, int, const(char)**) item_getter, void* userdata, int selected, int count, int item_height, nk_vec2 size);
void nk_combobox(nk_context*, const(char)** items, int count, int* selected, int item_height, nk_vec2 size);
void nk_combobox_string(nk_context*, const(char)* items_separated_by_zeros, int* selected, int count, int item_height, nk_vec2 size);
void nk_combobox_separator(nk_context*, const(char)* items_separated_by_separator, int separator, int* selected, int count, int item_height, nk_vec2 size);
void nk_combobox_callback(nk_context*, void function(void*, int, const(char)**) item_getter, void*, int* selected, int count, int item_height, nk_vec2 size);
int nk_combo_begin_text(nk_context*, const(char)* selected, int, nk_vec2 size);
int nk_combo_begin_label(nk_context*, const(char)* selected, nk_vec2 size);
int nk_combo_begin_color(nk_context*, nk_color color, nk_vec2 size);
int nk_combo_begin_symbol(nk_context*, nk_symbol_type, nk_vec2 size);
int nk_combo_begin_symbol_label(nk_context*, const(char)* selected, nk_symbol_type, nk_vec2 size);
int nk_combo_begin_symbol_text(nk_context*, const(char)* selected, int, nk_symbol_type, nk_vec2 size);
int nk_combo_begin_image(nk_context*, nk_image img, nk_vec2 size);
int nk_combo_begin_image_label(nk_context*, const(char)* selected, nk_image, nk_vec2 size);
int nk_combo_begin_image_text(nk_context*, const(char)* selected, int, nk_image, nk_vec2 size);
int nk_combo_item_label(nk_context*, const(char)*, nk_flags alignment);
int nk_combo_item_text(nk_context*, const(char)*, int, nk_flags alignment);
int nk_combo_item_image_label(nk_context*, nk_image, const(char)*, nk_flags alignment);
int nk_combo_item_image_text(nk_context*, nk_image, const(char)*, int, nk_flags alignment);
int nk_combo_item_symbol_label(nk_context*, nk_symbol_type, const(char)*, nk_flags alignment);
int nk_combo_item_symbol_text(nk_context*, nk_symbol_type, const(char)*, int, nk_flags alignment);
void nk_combo_close(nk_context*);
void nk_combo_end(nk_context*);
int nk_contextual_begin(nk_context*, nk_flags, nk_vec2, nk_rect trigger_bounds);
int nk_contextual_item_text(nk_context*, const(char)*, int, nk_flags align_);
int nk_contextual_item_label(nk_context*, const(char)*, nk_flags align_);
int nk_contextual_item_image_label(nk_context*, nk_image, const(char)*, nk_flags alignment);
int nk_contextual_item_image_text(nk_context*, nk_image, const(char)*, int len, nk_flags alignment);
int nk_contextual_item_symbol_label(nk_context*, nk_symbol_type, const(char)*, nk_flags alignment);
int nk_contextual_item_symbol_text(nk_context*, nk_symbol_type, const(char)*, int, nk_flags alignment);
void nk_contextual_close(nk_context*);
void nk_contextual_end(nk_context*);
void nk_tooltip(nk_context*, const(char)*);
void nk_tooltipf(nk_context*, const(char)*, ...);
void nk_tooltipfv(nk_context*, const(char)*, va_list);
int nk_tooltip_begin(nk_context*, float width);
void nk_tooltip_end(nk_context*);
void nk_menubar_begin(nk_context*);
void nk_menubar_end(nk_context*);
int nk_menu_begin_text(nk_context*, const(char)* title, int title_len, nk_flags align_, nk_vec2 size);
int nk_menu_begin_label(nk_context*, const(char)*, nk_flags align_, nk_vec2 size);
int nk_menu_begin_image(nk_context*, const(char)*, nk_image, nk_vec2 size);
int nk_menu_begin_image_text(nk_context*, const(char)*, int, nk_flags align_, nk_image, nk_vec2 size);
int nk_menu_begin_image_label(nk_context*, const(char)*, nk_flags align_, nk_image, nk_vec2 size);
int nk_menu_begin_symbol(nk_context*, const(char)*, nk_symbol_type, nk_vec2 size);
int nk_menu_begin_symbol_text(nk_context*, const(char)*, int, nk_flags align_, nk_symbol_type, nk_vec2 size);
int nk_menu_begin_symbol_label(nk_context*, const(char)*, nk_flags align_, nk_symbol_type, nk_vec2 size);
int nk_menu_item_text(nk_context*, const(char)*, int, nk_flags align_);
int nk_menu_item_label(nk_context*, const(char)*, nk_flags alignment);
int nk_menu_item_image_label(nk_context*, nk_image, const(char)*, nk_flags alignment);
int nk_menu_item_image_text(nk_context*, nk_image, const(char)*, int len, nk_flags alignment);
int nk_menu_item_symbol_text(nk_context*, nk_symbol_type, const(char)*, int, nk_flags alignment);
int nk_menu_item_symbol_label(nk_context*, nk_symbol_type, const(char)*, nk_flags alignment);
void nk_menu_close(nk_context*);
void nk_menu_end(nk_context*);
void nk_style_default(nk_context*);
void nk_style_from_table(nk_context*, const(nk_color)*);
void nk_style_load_cursor(nk_context*, nk_style_cursor, const(nk_cursor)*);
void nk_style_load_all_cursors(nk_context*, nk_cursor*);
const(char)* nk_style_get_color_by_name(nk_style_colors);
void nk_style_set_font(nk_context*, const(nk_user_font)*);
int nk_style_set_cursor(nk_context*, nk_style_cursor);
void nk_style_show_cursor(nk_context*);
void nk_style_hide_cursor(nk_context*);
int nk_style_push_font(nk_context*, const(nk_user_font)*);
int nk_style_push_float(nk_context*, float*, float);
int nk_style_push_vec2(nk_context*, nk_vec2*, nk_vec2);
int nk_style_push_style_item(nk_context*, nk_style_item*, nk_style_item);
int nk_style_push_flags(nk_context*, nk_flags*, nk_flags);
int nk_style_push_color(nk_context*, nk_color*, nk_color);
int nk_style_pop_font(nk_context*);
int nk_style_pop_float(nk_context*);
int nk_style_pop_vec2(nk_context*);
int nk_style_pop_style_item(nk_context*);
int nk_style_pop_flags(nk_context*);
int nk_style_pop_color(nk_context*);
nk_color nk_rgb(int r, int g, int b);
nk_color nk_rgb_iv(const(int)* rgb);
nk_color nk_rgb_bv(const(nk_byte)* rgb);
nk_color nk_rgb_f(float r, float g, float b);
nk_color nk_rgb_fv(const(float)* rgb);
nk_color nk_rgb_cf(nk_colorf c);
nk_color nk_rgb_hex(const(char)* rgb);
nk_color nk_rgba(int r, int g, int b, int a);
nk_color nk_rgba_u32(nk_uint);
nk_color nk_rgba_iv(const(int)* rgba);
nk_color nk_rgba_bv(const(nk_byte)* rgba);
nk_color nk_rgba_f(float r, float g, float b, float a);
nk_color nk_rgba_fv(const(float)* rgba);
nk_color nk_rgba_cf(nk_colorf c);
nk_color nk_rgba_hex(const(char)* rgb);
nk_colorf nk_hsva_colorf(float h, float s, float v, float a);
nk_colorf nk_hsva_colorfv(float* c);
void nk_colorf_hsva_f(float* out_h, float* out_s, float* out_v, float* out_a, nk_colorf in_);
void nk_colorf_hsva_fv(float* hsva, nk_colorf in_);
nk_color nk_hsv(int h, int s, int v);
nk_color nk_hsv_iv(const(int)* hsv);
nk_color nk_hsv_bv(const(nk_byte)* hsv);
nk_color nk_hsv_f(float h, float s, float v);
nk_color nk_hsv_fv(const(float)* hsv);
nk_color nk_hsva(int h, int s, int v, int a);
nk_color nk_hsva_iv(const(int)* hsva);
nk_color nk_hsva_bv(const(nk_byte)* hsva);
nk_color nk_hsva_f(float h, float s, float v, float a);
nk_color nk_hsva_fv(const(float)* hsva);
void nk_color_f(float* r, float* g, float* b, float* a, nk_color);
void nk_color_fv(float* rgba_out, nk_color);
nk_colorf nk_color_cf(nk_color);
void nk_color_d(double* r, double* g, double* b, double* a, nk_color);
void nk_color_dv(double* rgba_out, nk_color);
nk_uint nk_color_u32(nk_color);
void nk_color_hex_rgba(char* output, nk_color);
void nk_color_hex_rgb(char* output, nk_color);
void nk_color_hsv_i(int* out_h, int* out_s, int* out_v, nk_color);
void nk_color_hsv_b(nk_byte* out_h, nk_byte* out_s, nk_byte* out_v, nk_color);
void nk_color_hsv_iv(int* hsv_out, nk_color);
void nk_color_hsv_bv(nk_byte* hsv_out, nk_color);
void nk_color_hsv_f(float* out_h, float* out_s, float* out_v, nk_color);
void nk_color_hsv_fv(float* hsv_out, nk_color);
void nk_color_hsva_i(int* h, int* s, int* v, int* a, nk_color);
void nk_color_hsva_b(nk_byte* h, nk_byte* s, nk_byte* v, nk_byte* a, nk_color);
void nk_color_hsva_iv(int* hsva_out, nk_color);
void nk_color_hsva_bv(nk_byte* hsva_out, nk_color);
void nk_color_hsva_f(float* out_h, float* out_s, float* out_v, float* out_a, nk_color);
void nk_color_hsva_fv(float* hsva_out, nk_color);
nk_handle nk_handle_ptr(void*);
nk_handle nk_handle_id(int);
nk_image nk_image_handle(nk_handle);
nk_image nk_image_ptr(void*);
nk_image nk_image_id(int);
int nk_image_is_subimage(const(nk_image)* img);
nk_image nk_subimage_ptr(void*, ushort w, ushort h, nk_rect sub_region);
nk_image nk_subimage_id(int, ushort w, ushort h, nk_rect sub_region);
nk_image nk_subimage_handle(nk_handle, ushort w, ushort h, nk_rect sub_region);
nk_hash nk_murmur_hash(const(void)* key, int len, nk_hash seed);
void nk_triangle_from_direction(nk_vec2* result, nk_rect r, float pad_x, float pad_y, nk_heading);
pragma(mangle, `nk_vec2`) nk_vec2 nk_vec2_(float x, float y);
pragma(mangle, `nk_vec2i`) nk_vec2 nk_vec2i_(int x, int y);
nk_vec2 nk_vec2v(const(float)* xy);
nk_vec2 nk_vec2iv(const(int)* xy);
nk_rect nk_get_null_rect();
pragma(mangle, `nk_rect`) nk_rect nk_rect_(float x, float y, float w, float h);
pragma(mangle, `nk_recti`) nk_rect nk_recti_(int x, int y, int w, int h);
nk_rect nk_recta(nk_vec2 pos, nk_vec2 size);
nk_rect nk_rectv(const(float)* xywh);
nk_rect nk_rectiv(const(int)* xywh);
nk_vec2 nk_rect_pos(nk_rect);
nk_vec2 nk_rect_size(nk_rect);
int nk_strlen(const(char)* str);
int nk_stricmp(const(char)* s1, const(char)* s2);
int nk_stricmpn(const(char)* s1, const(char)* s2, int n);
int nk_strtoi(const(char)* str, const(char)** endptr);
float nk_strtof(const(char)* str, const(char)** endptr);
double nk_strtod(const(char)* str, const(char)** endptr);
int nk_strfilter(const(char)* text, const(char)* regexp);
int nk_strmatch_fuzzy_text(const(char)* txt, int txt_len, const(char)* pattern, int* out_score);
int nk_utf_decode(const(char)*, nk_rune*, int);
int nk_utf_encode(nk_rune, char*, int);
int nk_utf_len(const(char)*, int byte_len);
const(char)* nk_utf_at(const(char)* buffer, int length, int index, nk_rune* unicode, int* len);
const(nk_rune)* nk_font_default_glyph_ranges();
const(nk_rune)* nk_font_chinese_glyph_ranges();
const(nk_rune)* nk_font_cyrillic_glyph_ranges();
const(nk_rune)* nk_font_korean_glyph_ranges();
void nk_font_atlas_init_default(nk_font_atlas*);
void nk_font_atlas_init(nk_font_atlas*, nk_allocator*);
void nk_font_atlas_init_custom(nk_font_atlas*, nk_allocator* persistent, nk_allocator* transient);
void nk_font_atlas_begin(nk_font_atlas*);
pragma(mangle, `nk_font_config`) nk_font_config nk_font_config_(float pixel_height);
nk_font* nk_font_atlas_add(nk_font_atlas*, const(nk_font_config)*);
nk_font* nk_font_atlas_add_from_memory(nk_font_atlas* atlas, void* memory, nk_size size, float height, const(nk_font_config)* config);
nk_font* nk_font_atlas_add_compressed(nk_font_atlas*, void* memory, nk_size size, float height, const(nk_font_config)*);
nk_font* nk_font_atlas_add_compressed_base85(nk_font_atlas*, const(char)* data, float height, const(nk_font_config)* config);
const(void)* nk_font_atlas_bake(nk_font_atlas*, int* width, int* height, nk_font_atlas_format);
void nk_font_atlas_end(nk_font_atlas*, nk_handle tex, nk_draw_null_texture*);
const(nk_font_glyph)* nk_font_find_glyph(nk_font*, nk_rune unicode);
void nk_font_atlas_cleanup(nk_font_atlas* atlas);
void nk_font_atlas_clear(nk_font_atlas*);
void nk_buffer_init_default(nk_buffer*);
void nk_buffer_init(nk_buffer*, const(nk_allocator)*, nk_size size);
void nk_buffer_init_fixed(nk_buffer*, void* memory, nk_size size);
void nk_buffer_info(nk_memory_status*, nk_buffer*);
void nk_buffer_push(nk_buffer*, nk_buffer_allocation_type type, const(void)* memory, nk_size size, nk_size align_);
void nk_buffer_mark(nk_buffer*, nk_buffer_allocation_type type);
void nk_buffer_reset(nk_buffer*, nk_buffer_allocation_type type);
void nk_buffer_clear(nk_buffer*);
void nk_buffer_free(nk_buffer*);
void* nk_buffer_memory(nk_buffer*);
const(void)* nk_buffer_memory_const(const(nk_buffer)*);
nk_size nk_buffer_total(nk_buffer*);
void nk_str_init_default(nk_str*);
void nk_str_init(nk_str*, const(nk_allocator)*, nk_size size);
void nk_str_init_fixed(nk_str*, void* memory, nk_size size);
void nk_str_clear(nk_str*);
void nk_str_free(nk_str*);
int nk_str_append_text_char(nk_str*, const(char)*, int);
int nk_str_append_str_char(nk_str*, const(char)*);
int nk_str_append_text_utf8(nk_str*, const(char)*, int);
int nk_str_append_str_utf8(nk_str*, const(char)*);
int nk_str_append_text_runes(nk_str*, const(nk_rune)*, int);
int nk_str_append_str_runes(nk_str*, const(nk_rune)*);
int nk_str_insert_at_char(nk_str*, int pos, const(char)*, int);
int nk_str_insert_at_rune(nk_str*, int pos, const(char)*, int);
int nk_str_insert_text_char(nk_str*, int pos, const(char)*, int);
int nk_str_insert_str_char(nk_str*, int pos, const(char)*);
int nk_str_insert_text_utf8(nk_str*, int pos, const(char)*, int);
int nk_str_insert_str_utf8(nk_str*, int pos, const(char)*);
int nk_str_insert_text_runes(nk_str*, int pos, const(nk_rune)*, int);
int nk_str_insert_str_runes(nk_str*, int pos, const(nk_rune)*);
void nk_str_remove_chars(nk_str*, int len);
void nk_str_remove_runes(nk_str* str, int len);
void nk_str_delete_chars(nk_str*, int pos, int len);
void nk_str_delete_runes(nk_str*, int pos, int len);
char* nk_str_at_char(nk_str*, int pos);
char* nk_str_at_rune(nk_str*, int pos, nk_rune* unicode, int* len);
nk_rune nk_str_rune_at(const(nk_str)*, int pos);
const(char)* nk_str_at_char_const(const(nk_str)*, int pos);
const(char)* nk_str_at_const(const(nk_str)*, int pos, nk_rune* unicode, int* len);
char* nk_str_get(nk_str*);
const(char)* nk_str_get_const(const(nk_str)*);
int nk_str_len(nk_str*);
int nk_str_len_char(nk_str*);
int nk_filter_default(const(nk_text_edit)*, nk_rune unicode);
int nk_filter_ascii(const(nk_text_edit)*, nk_rune unicode);
int nk_filter_float(const(nk_text_edit)*, nk_rune unicode);
int nk_filter_decimal(const(nk_text_edit)*, nk_rune unicode);
int nk_filter_hex(const(nk_text_edit)*, nk_rune unicode);
int nk_filter_oct(const(nk_text_edit)*, nk_rune unicode);
int nk_filter_binary(const(nk_text_edit)*, nk_rune unicode);
void nk_textedit_init_default(nk_text_edit*);
void nk_textedit_init(nk_text_edit*, nk_allocator*, nk_size size);
void nk_textedit_init_fixed(nk_text_edit*, void* memory, nk_size size);
void nk_textedit_free(nk_text_edit*);
void nk_textedit_text(nk_text_edit*, const(char)*, int total_len);
void nk_textedit_delete(nk_text_edit*, int where, int len);
void nk_textedit_delete_selection(nk_text_edit*);
void nk_textedit_select_all(nk_text_edit*);
int nk_textedit_cut(nk_text_edit*);
void nk_textedit_undo(nk_text_edit*);
void nk_textedit_redo(nk_text_edit*);
void nk_stroke_line(nk_command_buffer* b, float x0, float y0, float x1, float y1, float line_thickness, nk_color);
void nk_stroke_curve(nk_command_buffer*, float, float, float, float, float, float, float, float, float line_thickness, nk_color);
void nk_stroke_rect(nk_command_buffer*, nk_rect, float rounding, float line_thickness, nk_color);
void nk_stroke_circle(nk_command_buffer*, nk_rect, float line_thickness, nk_color);
void nk_stroke_arc(nk_command_buffer*, float cx, float cy, float radius, float a_min, float a_max, float line_thickness, nk_color);
void nk_stroke_triangle(nk_command_buffer*, float, float, float, float, float, float, float line_thichness, nk_color);
void nk_stroke_polyline(nk_command_buffer*, float* points, int point_count, float line_thickness, nk_color col);
void nk_stroke_polygon(nk_command_buffer*, float*, int point_count, float line_thickness, nk_color);
void nk_fill_rect(nk_command_buffer*, nk_rect, float rounding, nk_color);
void nk_fill_rect_multi_color(nk_command_buffer*, nk_rect, nk_color left, nk_color top, nk_color right, nk_color bottom);
void nk_fill_circle(nk_command_buffer*, nk_rect, nk_color);
void nk_fill_arc(nk_command_buffer*, float cx, float cy, float radius, float a_min, float a_max, nk_color);
void nk_fill_triangle(nk_command_buffer*, float x0, float y0, float x1, float y1, float x2, float y2, nk_color);
void nk_fill_polygon(nk_command_buffer*, float*, int point_count, nk_color);
void nk_draw_image(nk_command_buffer*, nk_rect, const(nk_image)*, nk_color);
void nk_draw_text(nk_command_buffer*, nk_rect, const(char)* text, int len, const(nk_user_font)*, nk_color, nk_color);
void nk_push_scissor(nk_command_buffer*, nk_rect);
void nk_push_custom(nk_command_buffer*, nk_rect, nk_command_custom_callback, nk_handle usr);
int nk_input_has_mouse_click(const(nk_input)*, nk_buttons);
int nk_input_has_mouse_click_in_rect(const(nk_input)*, nk_buttons, nk_rect);
int nk_input_has_mouse_click_down_in_rect(const(nk_input)*, nk_buttons, nk_rect, int down);
int nk_input_is_mouse_click_in_rect(const(nk_input)*, nk_buttons, nk_rect);
int nk_input_is_mouse_click_down_in_rect(const(nk_input)* i, nk_buttons id, nk_rect b, int down);
int nk_input_any_mouse_click_in_rect(const(nk_input)*, nk_rect);
int nk_input_is_mouse_prev_hovering_rect(const(nk_input)*, nk_rect);
int nk_input_is_mouse_hovering_rect(const(nk_input)*, nk_rect);
int nk_input_mouse_clicked(const(nk_input)*, nk_buttons, nk_rect);
int nk_input_is_mouse_down(const(nk_input)*, nk_buttons);
int nk_input_is_mouse_pressed(const(nk_input)*, nk_buttons);
int nk_input_is_mouse_released(const(nk_input)*, nk_buttons);
int nk_input_is_key_pressed(const(nk_input)*, nk_keys);
int nk_input_is_key_released(const(nk_input)*, nk_keys);
int nk_input_is_key_down(const(nk_input)*, nk_keys);
void nk_draw_list_init(nk_draw_list*);
void nk_draw_list_setup(nk_draw_list*, const(nk_convert_config)*, nk_buffer* cmds, nk_buffer* vertices, nk_buffer* elements, nk_anti_aliasing line_aa, nk_anti_aliasing shape_aa);
const(nk_draw_command)* nk__draw_list_begin(const(nk_draw_list)*, const(nk_buffer)*);
const(nk_draw_command)* nk__draw_list_next(const(nk_draw_command)*, const(nk_buffer)*, const(nk_draw_list)*);
const(nk_draw_command)* nk__draw_list_end(const(nk_draw_list)*, const(nk_buffer)*);
void nk_draw_list_path_clear(nk_draw_list*);
void nk_draw_list_path_line_to(nk_draw_list*, nk_vec2 pos);
void nk_draw_list_path_arc_to_fast(nk_draw_list*, nk_vec2 center, float radius, int a_min, int a_max);
void nk_draw_list_path_arc_to(nk_draw_list*, nk_vec2 center, float radius, float a_min, float a_max, uint segments);
void nk_draw_list_path_rect_to(nk_draw_list*, nk_vec2 a, nk_vec2 b, float rounding);
void nk_draw_list_path_curve_to(nk_draw_list*, nk_vec2 p2, nk_vec2 p3, nk_vec2 p4, uint num_segments);
void nk_draw_list_path_fill(nk_draw_list*, nk_color);
void nk_draw_list_path_stroke(nk_draw_list*, nk_color, nk_draw_list_stroke closed, float thickness);
void nk_draw_list_stroke_line(nk_draw_list*, nk_vec2 a, nk_vec2 b, nk_color, float thickness);
void nk_draw_list_stroke_rect(nk_draw_list*, nk_rect rect, nk_color, float rounding, float thickness);
void nk_draw_list_stroke_triangle(nk_draw_list*, nk_vec2 a, nk_vec2 b, nk_vec2 c, nk_color, float thickness);
void nk_draw_list_stroke_circle(nk_draw_list*, nk_vec2 center, float radius, nk_color, uint segs, float thickness);
void nk_draw_list_stroke_curve(nk_draw_list*, nk_vec2 p0, nk_vec2 cp0, nk_vec2 cp1, nk_vec2 p1, nk_color, uint segments, float thickness);
void nk_draw_list_stroke_poly_line(nk_draw_list*, const(nk_vec2)* pnts, const(uint) cnt, nk_color, nk_draw_list_stroke, float thickness, nk_anti_aliasing);
void nk_draw_list_fill_rect(nk_draw_list*, nk_rect rect, nk_color, float rounding);
void nk_draw_list_fill_rect_multi_color(nk_draw_list*, nk_rect rect, nk_color left, nk_color top, nk_color right, nk_color bottom);
void nk_draw_list_fill_triangle(nk_draw_list*, nk_vec2 a, nk_vec2 b, nk_vec2 c, nk_color);
void nk_draw_list_fill_circle(nk_draw_list*, nk_vec2 center, float radius, nk_color col, uint segs);
void nk_draw_list_fill_poly_convex(nk_draw_list*, const(nk_vec2)* points, const(uint) count, nk_color, nk_anti_aliasing);
void nk_draw_list_add_image(nk_draw_list*, nk_image texture, nk_rect rect, nk_color);
void nk_draw_list_add_text(nk_draw_list*, const(nk_user_font)*, nk_rect, const(char)* text, int len, float font_height, nk_color);
nk_style_item nk_style_item_image(nk_image img);
nk_style_item nk_style_item_color(nk_color);
nk_style_item nk_style_item_hide();
