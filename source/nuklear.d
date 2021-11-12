module nuklear;
public import core.stdc.stdarg, core.stdc.config;

enum NK_UTF_SIZE = 4;
static immutable NK_VERTEX_LAYOUT_END = nk_draw_vertex_layout_element(NK_VERTEX_ATTRIBUTE_COUNT, NK_FORMAT_COUNT, 0);

extern (C)
{
	struct nk_pool
	{
		nk_allocator alloc;
		nk_allocation_type type;
		uint page_count;
		nk_page* pages;
		nk_page_element* freelist;
		uint capacity;
		size_t size;
		size_t cap;
	}

	struct nk_page
	{
		uint size;
		nk_page* next;
		nk_page_element[1] win;
	}

	struct nk_page_element
	{
		nk_page_data data;
		nk_page_element* next;
		nk_page_element* prev;
	}

	union nk_page_data
	{
		nk_table tbl;
		nk_panel pan;
		nk_window win;
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

	struct nk_config_stack_button_behavior
	{
		int head;
		nk_config_stack_button_behavior_element[8] elements;
	}

	struct nk_config_stack_user_font
	{
		int head;
		nk_config_stack_user_font_element[8] elements;
	}

	struct nk_config_stack_color
	{
		int head;
		nk_config_stack_color_element[32] elements;
	}

	struct nk_config_stack_flags
	{
		int head;
		nk_config_stack_flags_element[32] elements;
	}

	struct nk_config_stack_vec2
	{
		int head;
		nk_config_stack_vec2_element[16] elements;
	}

	struct nk_config_stack_float
	{
		int head;
		nk_config_stack_float_element[32] elements;
	}

	struct nk_config_stack_style_item
	{
		int head;
		nk_config_stack_style_item_element[16] elements;
	}

	struct nk_config_stack_button_behavior_element
	{
		nk_button_behavior* address;
		nk_button_behavior old_value;
	}

	struct nk_config_stack_user_font_element
	{
		const(nk_user_font)** address;
		const(nk_user_font)* old_value;
	}

	struct nk_config_stack_color_element
	{
		nk_color* address;
		nk_color old_value;
	}

	struct nk_config_stack_flags_element
	{
		uint* address;
		uint old_value;
	}

	struct nk_config_stack_vec2_element
	{
		nk_vec2* address;
		nk_vec2 old_value;
	}

	struct nk_config_stack_float_element
	{
		float* address;
		float old_value;
	}

	struct nk_config_stack_style_item_element
	{
		nk_style_item* address;
		nk_style_item old_value;
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
		uint name;
		uint seq;
		uint old;
		int state;
	}

	struct nk_edit_state
	{
		uint name;
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

	struct nk_popup_state
	{
		nk_window* win;
		nk_panel_type type;
		nk_popup_buffer buf;
		uint name;
		bool active;
		uint combo_count;
		uint con_count;
		uint con_old;
		uint active_con;
		nk_rect header;
	}

	enum nk_window_flags
	{
		NK_WINDOW_PRIVATE = 2048,
		NK_WINDOW_DYNAMIC = 2048,
		NK_WINDOW_ROM = 4096,
		NK_WINDOW_NOT_INTERACTIVE = 5120,
		NK_WINDOW_HIDDEN = 8192,
		NK_WINDOW_CLOSED = 16384,
		NK_WINDOW_MINIMIZED = 32768,
		NK_WINDOW_REMOVE_ROM = 65536,
	}

	enum NK_WINDOW_PRIVATE = nk_window_flags.NK_WINDOW_PRIVATE;
	enum NK_WINDOW_DYNAMIC = nk_window_flags.NK_WINDOW_DYNAMIC;
	enum NK_WINDOW_ROM = nk_window_flags.NK_WINDOW_ROM;
	enum NK_WINDOW_NOT_INTERACTIVE = nk_window_flags.NK_WINDOW_NOT_INTERACTIVE;
	enum NK_WINDOW_HIDDEN = nk_window_flags.NK_WINDOW_HIDDEN;
	enum NK_WINDOW_CLOSED = nk_window_flags.NK_WINDOW_CLOSED;
	enum NK_WINDOW_MINIMIZED = nk_window_flags.NK_WINDOW_MINIMIZED;
	enum NK_WINDOW_REMOVE_ROM = nk_window_flags.NK_WINDOW_REMOVE_ROM;
	struct nk_table
	{
		uint seq;
		uint size;
		uint[51] keys;
		uint[51] values;
		nk_table* next;
		nk_table* prev;
	}

	struct nk_menu_state
	{
		float x;
		float y;
		float w;
		float h;
		nk_scroll offset;
	}

	struct nk_popup_buffer
	{
		size_t begin;
		size_t parent;
		size_t last;
		size_t end;
		bool active;
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

	enum nk_panel_row_layout_type
	{
		NK_LAYOUT_DYNAMIC_FIXED = 0,
		NK_LAYOUT_DYNAMIC_ROW = 1,
		NK_LAYOUT_DYNAMIC_FREE = 2,
		NK_LAYOUT_DYNAMIC = 3,
		NK_LAYOUT_STATIC_FIXED = 4,
		NK_LAYOUT_STATIC_ROW = 5,
		NK_LAYOUT_STATIC_FREE = 6,
		NK_LAYOUT_STATIC = 7,
		NK_LAYOUT_TEMPLATE = 8,
		NK_LAYOUT_COUNT = 9,
	}

	enum NK_LAYOUT_DYNAMIC_FIXED = nk_panel_row_layout_type.NK_LAYOUT_DYNAMIC_FIXED;
	enum NK_LAYOUT_DYNAMIC_ROW = nk_panel_row_layout_type.NK_LAYOUT_DYNAMIC_ROW;
	enum NK_LAYOUT_DYNAMIC_FREE = nk_panel_row_layout_type.NK_LAYOUT_DYNAMIC_FREE;
	enum NK_LAYOUT_DYNAMIC = nk_panel_row_layout_type.NK_LAYOUT_DYNAMIC;
	enum NK_LAYOUT_STATIC_FIXED = nk_panel_row_layout_type.NK_LAYOUT_STATIC_FIXED;
	enum NK_LAYOUT_STATIC_ROW = nk_panel_row_layout_type.NK_LAYOUT_STATIC_ROW;
	enum NK_LAYOUT_STATIC_FREE = nk_panel_row_layout_type.NK_LAYOUT_STATIC_FREE;
	enum NK_LAYOUT_STATIC = nk_panel_row_layout_type.NK_LAYOUT_STATIC;
	enum NK_LAYOUT_TEMPLATE = nk_panel_row_layout_type.NK_LAYOUT_TEMPLATE;
	enum NK_LAYOUT_COUNT = nk_panel_row_layout_type.NK_LAYOUT_COUNT;
	struct nk_chart
	{
		int slot;
		float x;
		float y;
		float w;
		float h;
		nk_chart_slot[4] slots;
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

	enum nk_panel_set
	{
		NK_PANEL_SET_NONBLOCK = 240,
		NK_PANEL_SET_POPUP = 244,
		NK_PANEL_SET_SUB = 246,
	}

	enum NK_PANEL_SET_NONBLOCK = nk_panel_set.NK_PANEL_SET_NONBLOCK;
	enum NK_PANEL_SET_POPUP = nk_panel_set.NK_PANEL_SET_POPUP;
	enum NK_PANEL_SET_SUB = nk_panel_set.NK_PANEL_SET_SUB;
	enum nk_panel_type
	{
		NK_PANEL_NONE = 0,
		NK_PANEL_WINDOW = 1,
		NK_PANEL_GROUP = 2,
		NK_PANEL_POPUP = 4,
		NK_PANEL_CONTEXTUAL = 16,
		NK_PANEL_COMBO = 32,
		NK_PANEL_MENU = 64,
		NK_PANEL_TOOLTIP = 128,
	}

	enum NK_PANEL_NONE = nk_panel_type.NK_PANEL_NONE;
	enum NK_PANEL_WINDOW = nk_panel_type.NK_PANEL_WINDOW;
	enum NK_PANEL_GROUP = nk_panel_type.NK_PANEL_GROUP;
	enum NK_PANEL_POPUP = nk_panel_type.NK_PANEL_POPUP;
	enum NK_PANEL_CONTEXTUAL = nk_panel_type.NK_PANEL_CONTEXTUAL;
	enum NK_PANEL_COMBO = nk_panel_type.NK_PANEL_COMBO;
	enum NK_PANEL_MENU = nk_panel_type.NK_PANEL_MENU;
	enum NK_PANEL_TOOLTIP = nk_panel_type.NK_PANEL_TOOLTIP;
	nk_style_item nk_style_item_hide() @nogc nothrow;
	nk_style_item nk_style_item_nine_slice(nk_nine_slice) @nogc nothrow;
	nk_style_item nk_style_item_image(nk_image) @nogc nothrow;
	nk_style_item nk_style_item_color(nk_color) @nogc nothrow;
	struct nk_style
	{
		const(nk_user_font)* font;
		const(nk_cursor)*[7] cursors;
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

	enum nk_style_header_align
	{
		NK_HEADER_LEFT = 0,
		NK_HEADER_RIGHT = 1,
	}

	enum NK_HEADER_LEFT = nk_style_header_align.NK_HEADER_LEFT;
	enum NK_HEADER_RIGHT = nk_style_header_align.NK_HEADER_RIGHT;
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

	struct nk_style_text
	{
		nk_color color;
		nk_vec2 padding;
	}

	union nk_style_item_data
	{
		nk_color color;
		nk_image image;
		nk_nine_slice slice;
	}

	enum nk_style_item_type
	{
		NK_STYLE_ITEM_COLOR = 0,
		NK_STYLE_ITEM_IMAGE = 1,
		NK_STYLE_ITEM_NINE_SLICE = 2,
	}

	enum NK_STYLE_ITEM_COLOR = nk_style_item_type.NK_STYLE_ITEM_COLOR;
	enum NK_STYLE_ITEM_IMAGE = nk_style_item_type.NK_STYLE_ITEM_IMAGE;
	enum NK_STYLE_ITEM_NINE_SLICE = nk_style_item_type.NK_STYLE_ITEM_NINE_SLICE;
	void nk_draw_list_add_text(nk_draw_list*, const(nk_user_font)*, nk_rect, const(char)*, int, float, nk_color) @nogc nothrow;
	void nk_draw_list_add_image(nk_draw_list*, nk_image, nk_rect, nk_color) @nogc nothrow;
	void nk_draw_list_fill_poly_convex(nk_draw_list*, const(nk_vec2)*, const(uint), nk_color, nk_anti_aliasing) @nogc nothrow;
	void nk_draw_list_fill_circle(nk_draw_list*, nk_vec2, float, nk_color, uint) @nogc nothrow;
	void nk_draw_list_fill_triangle(nk_draw_list*, nk_vec2, nk_vec2, nk_vec2, nk_color) @nogc nothrow;
	void nk_draw_list_fill_rect_multi_color(nk_draw_list*, nk_rect, nk_color, nk_color, nk_color, nk_color) @nogc nothrow;
	void nk_draw_list_fill_rect(nk_draw_list*, nk_rect, nk_color, float) @nogc nothrow;
	void nk_draw_list_stroke_poly_line(nk_draw_list*, const(nk_vec2)*, const(uint), nk_color, nk_draw_list_stroke,
			float, nk_anti_aliasing) @nogc nothrow;
	void nk_draw_list_stroke_curve(nk_draw_list*, nk_vec2, nk_vec2, nk_vec2, nk_vec2, nk_color, uint, float) @nogc nothrow;
	void nk_draw_list_stroke_circle(nk_draw_list*, nk_vec2, float, nk_color, uint, float) @nogc nothrow;
	void nk_draw_list_stroke_triangle(nk_draw_list*, nk_vec2, nk_vec2, nk_vec2, nk_color, float) @nogc nothrow;
	void nk_draw_list_stroke_rect(nk_draw_list*, nk_rect, nk_color, float, float) @nogc nothrow;
	void nk_draw_list_stroke_line(nk_draw_list*, nk_vec2, nk_vec2, nk_color, float) @nogc nothrow;
	void nk_draw_list_path_stroke(nk_draw_list*, nk_color, nk_draw_list_stroke, float) @nogc nothrow;
	void nk_draw_list_path_fill(nk_draw_list*, nk_color) @nogc nothrow;
	void nk_draw_list_path_curve_to(nk_draw_list*, nk_vec2, nk_vec2, nk_vec2, uint) @nogc nothrow;
	void nk_draw_list_path_rect_to(nk_draw_list*, nk_vec2, nk_vec2, float) @nogc nothrow;
	void nk_draw_list_path_arc_to(nk_draw_list*, nk_vec2, float, float, float, uint) @nogc nothrow;
	void nk_draw_list_path_arc_to_fast(nk_draw_list*, nk_vec2, float, int, int) @nogc nothrow;
	void nk_draw_list_path_line_to(nk_draw_list*, nk_vec2) @nogc nothrow;
	void nk_draw_list_path_clear(nk_draw_list*) @nogc nothrow;
	const(nk_draw_command)* nk__draw_list_end(const(nk_draw_list)*, const(nk_buffer)*) @nogc nothrow;
	const(nk_draw_command)* nk__draw_list_next(const(nk_draw_command)*, const(nk_buffer)*, const(nk_draw_list)*) @nogc nothrow;
	const(nk_draw_command)* nk__draw_list_begin(const(nk_draw_list)*, const(nk_buffer)*) @nogc nothrow;
	void nk_draw_list_setup(nk_draw_list*, const(nk_convert_config)*, nk_buffer*, nk_buffer*, nk_buffer*,
			nk_anti_aliasing, nk_anti_aliasing) @nogc nothrow;
	void nk_draw_list_init(nk_draw_list*) @nogc nothrow;
	enum nk_draw_vertex_layout_format
	{
		NK_FORMAT_SCHAR = 0,
		NK_FORMAT_SSHORT = 1,
		NK_FORMAT_SINT = 2,
		NK_FORMAT_UCHAR = 3,
		NK_FORMAT_USHORT = 4,
		NK_FORMAT_UINT = 5,
		NK_FORMAT_FLOAT = 6,
		NK_FORMAT_DOUBLE = 7,
		NK_FORMAT_COLOR_BEGIN = 8,
		NK_FORMAT_R8G8B8 = 8,
		NK_FORMAT_R16G15B16 = 9,
		NK_FORMAT_R32G32B32 = 10,
		NK_FORMAT_R8G8B8A8 = 11,
		NK_FORMAT_B8G8R8A8 = 12,
		NK_FORMAT_R16G15B16A16 = 13,
		NK_FORMAT_R32G32B32A32 = 14,
		NK_FORMAT_R32G32B32A32_FLOAT = 15,
		NK_FORMAT_R32G32B32A32_DOUBLE = 16,
		NK_FORMAT_RGB32 = 17,
		NK_FORMAT_RGBA32 = 18,
		NK_FORMAT_COLOR_END = 18,
		NK_FORMAT_COUNT = 19,
	}

	enum NK_FORMAT_SCHAR = nk_draw_vertex_layout_format.NK_FORMAT_SCHAR;
	enum NK_FORMAT_SSHORT = nk_draw_vertex_layout_format.NK_FORMAT_SSHORT;
	enum NK_FORMAT_SINT = nk_draw_vertex_layout_format.NK_FORMAT_SINT;
	enum NK_FORMAT_UCHAR = nk_draw_vertex_layout_format.NK_FORMAT_UCHAR;
	enum NK_FORMAT_USHORT = nk_draw_vertex_layout_format.NK_FORMAT_USHORT;
	enum NK_FORMAT_UINT = nk_draw_vertex_layout_format.NK_FORMAT_UINT;
	enum NK_FORMAT_FLOAT = nk_draw_vertex_layout_format.NK_FORMAT_FLOAT;
	enum NK_FORMAT_DOUBLE = nk_draw_vertex_layout_format.NK_FORMAT_DOUBLE;
	enum NK_FORMAT_COLOR_BEGIN = nk_draw_vertex_layout_format.NK_FORMAT_COLOR_BEGIN;
	enum NK_FORMAT_R8G8B8 = nk_draw_vertex_layout_format.NK_FORMAT_R8G8B8;
	enum NK_FORMAT_R16G15B16 = nk_draw_vertex_layout_format.NK_FORMAT_R16G15B16;
	enum NK_FORMAT_R32G32B32 = nk_draw_vertex_layout_format.NK_FORMAT_R32G32B32;
	enum NK_FORMAT_R8G8B8A8 = nk_draw_vertex_layout_format.NK_FORMAT_R8G8B8A8;
	enum NK_FORMAT_B8G8R8A8 = nk_draw_vertex_layout_format.NK_FORMAT_B8G8R8A8;
	enum NK_FORMAT_R16G15B16A16 = nk_draw_vertex_layout_format.NK_FORMAT_R16G15B16A16;
	enum NK_FORMAT_R32G32B32A32 = nk_draw_vertex_layout_format.NK_FORMAT_R32G32B32A32;
	enum NK_FORMAT_R32G32B32A32_FLOAT = nk_draw_vertex_layout_format.NK_FORMAT_R32G32B32A32_FLOAT;
	enum NK_FORMAT_R32G32B32A32_DOUBLE = nk_draw_vertex_layout_format.NK_FORMAT_R32G32B32A32_DOUBLE;
	enum NK_FORMAT_RGB32 = nk_draw_vertex_layout_format.NK_FORMAT_RGB32;
	enum NK_FORMAT_RGBA32 = nk_draw_vertex_layout_format.NK_FORMAT_RGBA32;
	enum NK_FORMAT_COLOR_END = nk_draw_vertex_layout_format.NK_FORMAT_COLOR_END;
	enum NK_FORMAT_COUNT = nk_draw_vertex_layout_format.NK_FORMAT_COUNT;
	enum nk_draw_vertex_layout_attribute
	{
		NK_VERTEX_POSITION = 0,
		NK_VERTEX_COLOR = 1,
		NK_VERTEX_TEXCOORD = 2,
		NK_VERTEX_ATTRIBUTE_COUNT = 3,
	}

	enum NK_VERTEX_POSITION = nk_draw_vertex_layout_attribute.NK_VERTEX_POSITION;
	enum NK_VERTEX_COLOR = nk_draw_vertex_layout_attribute.NK_VERTEX_COLOR;
	enum NK_VERTEX_TEXCOORD = nk_draw_vertex_layout_attribute.NK_VERTEX_TEXCOORD;
	enum NK_VERTEX_ATTRIBUTE_COUNT = nk_draw_vertex_layout_attribute.NK_VERTEX_ATTRIBUTE_COUNT;
	enum nk_draw_list_stroke
	{
		NK_STROKE_OPEN = 0,
		NK_STROKE_CLOSED = 1,
	}

	enum NK_STROKE_OPEN = nk_draw_list_stroke.NK_STROKE_OPEN;
	enum NK_STROKE_CLOSED = nk_draw_list_stroke.NK_STROKE_CLOSED;
	alias nk_draw_index = uint;
	bool nk_input_is_key_down(const(nk_input)*, nk_keys) @nogc nothrow;
	bool nk_input_is_key_released(const(nk_input)*, nk_keys) @nogc nothrow;
	bool nk_input_is_key_pressed(const(nk_input)*, nk_keys) @nogc nothrow;
	bool nk_input_is_mouse_released(const(nk_input)*, nk_buttons) @nogc nothrow;
	bool nk_input_is_mouse_pressed(const(nk_input)*, nk_buttons) @nogc nothrow;
	bool nk_input_is_mouse_down(const(nk_input)*, nk_buttons) @nogc nothrow;
	bool nk_input_mouse_clicked(const(nk_input)*, nk_buttons, nk_rect) @nogc nothrow;
	bool nk_input_is_mouse_hovering_rect(const(nk_input)*, nk_rect) @nogc nothrow;
	bool nk_input_is_mouse_prev_hovering_rect(const(nk_input)*, nk_rect) @nogc nothrow;
	bool nk_input_any_mouse_click_in_rect(const(nk_input)*, nk_rect) @nogc nothrow;
	bool nk_input_is_mouse_click_down_in_rect(const(nk_input)*, nk_buttons, nk_rect, bool) @nogc nothrow;
	bool nk_input_is_mouse_click_in_rect(const(nk_input)*, nk_buttons, nk_rect) @nogc nothrow;
	bool nk_input_has_mouse_click_down_in_rect(const(nk_input)*, nk_buttons, nk_rect, bool) @nogc nothrow;
	bool nk_input_has_mouse_click_in_rect(const(nk_input)*, nk_buttons, nk_rect) @nogc nothrow;
	bool nk_input_has_mouse_click(const(nk_input)*, nk_buttons) @nogc nothrow;
	struct nk_input
	{
		nk_keyboard keyboard;
		nk_mouse mouse;
	}

	struct nk_keyboard
	{
		nk_key[30] keys;
		char[16] text;
		int text_len;
	}

	struct nk_key
	{
		bool down;
		uint clicked;
	}

	struct nk_mouse
	{
		nk_mouse_button[4] buttons;
		nk_vec2 pos;
		nk_vec2 prev;
		nk_vec2 delta;
		nk_vec2 scroll_delta;
		ubyte grab;
		ubyte grabbed;
		ubyte ungrab;
	}

	struct nk_mouse_button
	{
		bool down;
		uint clicked;
		nk_vec2 clicked_pos;
	}

	void nk_push_custom(nk_command_buffer*, nk_rect, void function(void*, short, short, ushort, ushort, nk_handle), nk_handle) @nogc nothrow;
	void nk_push_scissor(nk_command_buffer*, nk_rect) @nogc nothrow;
	void nk_draw_text(nk_command_buffer*, nk_rect, const(char)*, int, const(nk_user_font)*, nk_color, nk_color) @nogc nothrow;
	void nk_draw_nine_slice(nk_command_buffer*, nk_rect, const(nk_nine_slice)*, nk_color) @nogc nothrow;
	void nk_draw_image(nk_command_buffer*, nk_rect, const(nk_image)*, nk_color) @nogc nothrow;
	void nk_fill_polygon(nk_command_buffer*, float*, int, nk_color) @nogc nothrow;
	void nk_fill_triangle(nk_command_buffer*, float, float, float, float, float, float, nk_color) @nogc nothrow;
	void nk_fill_arc(nk_command_buffer*, float, float, float, float, float, nk_color) @nogc nothrow;
	void nk_fill_circle(nk_command_buffer*, nk_rect, nk_color) @nogc nothrow;
	void nk_fill_rect_multi_color(nk_command_buffer*, nk_rect, nk_color, nk_color, nk_color, nk_color) @nogc nothrow;
	void nk_fill_rect(nk_command_buffer*, nk_rect, float, nk_color) @nogc nothrow;
	void nk_stroke_polygon(nk_command_buffer*, float*, int, float, nk_color) @nogc nothrow;
	void nk_stroke_polyline(nk_command_buffer*, float*, int, float, nk_color) @nogc nothrow;
	void nk_stroke_triangle(nk_command_buffer*, float, float, float, float, float, float, float, nk_color) @nogc nothrow;
	void nk_stroke_arc(nk_command_buffer*, float, float, float, float, float, float, nk_color) @nogc nothrow;
	void nk_stroke_circle(nk_command_buffer*, nk_rect, float, nk_color) @nogc nothrow;
	void nk_stroke_rect(nk_command_buffer*, nk_rect, float, float, nk_color) @nogc nothrow;
	void nk_stroke_curve(nk_command_buffer*, float, float, float, float, float, float, float, float, float, nk_color) @nogc nothrow;
	void nk_stroke_line(nk_command_buffer*, float, float, float, float, float, nk_color) @nogc nothrow;
	enum nk_command_clipping
	{
		NK_CLIPPING_OFF = 0,
		NK_CLIPPING_ON = 1,
	}

	enum NK_CLIPPING_OFF = nk_command_clipping.NK_CLIPPING_OFF;
	enum NK_CLIPPING_ON = nk_command_clipping.NK_CLIPPING_ON;
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
		char[1] string_;
	}

	struct nk_command_custom
	{
		nk_command header;
		short x;
		short y;
		ushort w;
		ushort h;
		nk_handle callback_data;
		void function(void*, short, short, ushort, ushort, nk_handle) callback;
	}

	alias nk_command_custom_callback = void function(void*, short, short, ushort, ushort, nk_handle);
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

	struct nk_command_polyline
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

	struct nk_command_polygon
	{
		nk_command header;
		nk_color color;
		ushort line_thickness;
		ushort point_count;
		nk_vec2i[1] points;
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

	struct nk_command_circle_filled
	{
		nk_command header;
		short x;
		short y;
		ushort w;
		ushort h;
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

	struct nk_command_triangle_filled
	{
		nk_command header;
		nk_vec2i a;
		nk_vec2i b;
		nk_vec2i c;
		nk_color color;
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

	struct nk_command_curve
	{
		nk_command header;
		ushort line_thickness;
		nk_vec2i begin;
		nk_vec2i end;
		nk_vec2i[2] ctrl;
		nk_color color;
	}

	struct nk_command_line
	{
		nk_command header;
		ushort line_thickness;
		nk_vec2i begin;
		nk_vec2i end;
		nk_color color;
	}

	struct nk_command_scissor
	{
		nk_command header;
		short x;
		short y;
		ushort w;
		ushort h;
	}

	enum nk_command_type
	{
		NK_COMMAND_NOP = 0,
		NK_COMMAND_SCISSOR = 1,
		NK_COMMAND_LINE = 2,
		NK_COMMAND_CURVE = 3,
		NK_COMMAND_RECT = 4,
		NK_COMMAND_RECT_FILLED = 5,
		NK_COMMAND_RECT_MULTI_COLOR = 6,
		NK_COMMAND_CIRCLE = 7,
		NK_COMMAND_CIRCLE_FILLED = 8,
		NK_COMMAND_ARC = 9,
		NK_COMMAND_ARC_FILLED = 10,
		NK_COMMAND_TRIANGLE = 11,
		NK_COMMAND_TRIANGLE_FILLED = 12,
		NK_COMMAND_POLYGON = 13,
		NK_COMMAND_POLYGON_FILLED = 14,
		NK_COMMAND_POLYLINE = 15,
		NK_COMMAND_TEXT = 16,
		NK_COMMAND_IMAGE = 17,
		NK_COMMAND_CUSTOM = 18,
	}

	enum NK_COMMAND_NOP = nk_command_type.NK_COMMAND_NOP;
	enum NK_COMMAND_SCISSOR = nk_command_type.NK_COMMAND_SCISSOR;
	enum NK_COMMAND_LINE = nk_command_type.NK_COMMAND_LINE;
	enum NK_COMMAND_CURVE = nk_command_type.NK_COMMAND_CURVE;
	enum NK_COMMAND_RECT = nk_command_type.NK_COMMAND_RECT;
	enum NK_COMMAND_RECT_FILLED = nk_command_type.NK_COMMAND_RECT_FILLED;
	enum NK_COMMAND_RECT_MULTI_COLOR = nk_command_type.NK_COMMAND_RECT_MULTI_COLOR;
	enum NK_COMMAND_CIRCLE = nk_command_type.NK_COMMAND_CIRCLE;
	enum NK_COMMAND_CIRCLE_FILLED = nk_command_type.NK_COMMAND_CIRCLE_FILLED;
	enum NK_COMMAND_ARC = nk_command_type.NK_COMMAND_ARC;
	enum NK_COMMAND_ARC_FILLED = nk_command_type.NK_COMMAND_ARC_FILLED;
	enum NK_COMMAND_TRIANGLE = nk_command_type.NK_COMMAND_TRIANGLE;
	enum NK_COMMAND_TRIANGLE_FILLED = nk_command_type.NK_COMMAND_TRIANGLE_FILLED;
	enum NK_COMMAND_POLYGON = nk_command_type.NK_COMMAND_POLYGON;
	enum NK_COMMAND_POLYGON_FILLED = nk_command_type.NK_COMMAND_POLYGON_FILLED;
	enum NK_COMMAND_POLYLINE = nk_command_type.NK_COMMAND_POLYLINE;
	enum NK_COMMAND_TEXT = nk_command_type.NK_COMMAND_TEXT;
	enum NK_COMMAND_IMAGE = nk_command_type.NK_COMMAND_IMAGE;
	enum NK_COMMAND_CUSTOM = nk_command_type.NK_COMMAND_CUSTOM;
	void nk_textedit_redo(nk_text_edit*) @nogc nothrow;
	void nk_textedit_undo(nk_text_edit*) @nogc nothrow;
	bool nk_textedit_paste(nk_text_edit*, const(char)*, int) @nogc nothrow;
	bool nk_textedit_cut(nk_text_edit*) @nogc nothrow;
	void nk_textedit_select_all(nk_text_edit*) @nogc nothrow;
	void nk_textedit_delete_selection(nk_text_edit*) @nogc nothrow;
	void nk_textedit_delete(nk_text_edit*, int, int) @nogc nothrow;
	void nk_textedit_text(nk_text_edit*, const(char)*, int) @nogc nothrow;
	void nk_textedit_free(nk_text_edit*) @nogc nothrow;
	void nk_textedit_init_fixed(nk_text_edit*, void*, size_t) @nogc nothrow;
	void nk_textedit_init(nk_text_edit*, nk_allocator*, size_t) @nogc nothrow;
	void nk_textedit_init_default(nk_text_edit*) @nogc nothrow;
	bool nk_filter_binary(const(nk_text_edit)*, uint) @nogc nothrow;
	bool nk_filter_oct(const(nk_text_edit)*, uint) @nogc nothrow;
	bool nk_filter_hex(const(nk_text_edit)*, uint) @nogc nothrow;
	bool nk_filter_decimal(const(nk_text_edit)*, uint) @nogc nothrow;
	bool nk_filter_float(const(nk_text_edit)*, uint) @nogc nothrow;
	bool nk_filter_ascii(const(nk_text_edit)*, uint) @nogc nothrow;
	alias nk_char = byte;
	alias nk_uchar = ubyte;
	alias nk_byte = ubyte;
	alias nk_short = short;
	alias nk_ushort = ushort;
	alias nk_int = int;
	alias nk_uint = uint;
	alias nk_size = size_t;
	alias nk_ptr = size_t;
	alias nk_bool = bool;
	alias nk_hash = uint;
	alias nk_flags = uint;
	alias nk_rune = uint;
	alias _dummy_array0 = char[1];
	alias _dummy_array1 = char[1];
	alias _dummy_array2 = char[1];
	alias _dummy_array3 = char[1];
	alias _dummy_array4 = char[1];
	alias _dummy_array5 = char[1];
	alias _dummy_array6 = char[1];
	alias _dummy_array7 = char[1];
	alias _dummy_array8 = char[1];
	alias _dummy_array9 = char[1];
	struct nk_buffer
	{
		nk_buffer_marker[2] marker;
		nk_allocator pool;
		nk_allocation_type type;
		nk_memory memory;
		float grow_factor;
		size_t allocated;
		size_t needed;
		size_t calls;
		size_t size;
	}

	struct nk_allocator
	{
		nk_handle userdata;
		void* function(nk_handle, void*, size_t) alloc;
		void function(nk_handle, void*) free;
	}

	struct nk_command_buffer
	{
		nk_buffer* base;
		nk_rect clip;
		int use_clipping;
		nk_handle userdata;
		size_t begin;
		size_t end;
		size_t last;
	}

	struct nk_draw_command
	{
		uint elem_count;
		nk_rect clip_rect;
		nk_handle texture;
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
		size_t vertex_size;
		size_t vertex_alignment;
	}

	struct nk_style_item
	{
		nk_style_item_type type;
		nk_style_item_data data;
	}

	struct nk_text_edit
	{
		nk_clipboard clip;
		nk_str string_;
		bool function(const(nk_text_edit)*, uint) filter;
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
		size_t cmd_offset;
		uint path_count;
		uint path_offset;
		nk_anti_aliasing line_AA;
		nk_anti_aliasing shape_AA;
	}

	struct nk_user_font
	{
		nk_handle userdata;
		float height;
		float function(nk_handle, float, const(char)*, int) width;
		void function(nk_handle, float, nk_user_font_glyph*, uint, uint) query;
		nk_handle texture;
	}

	struct nk_panel
	{
		nk_panel_type type;
		uint flags;
		nk_rect bounds;
		uint* offset_x;
		uint* offset_y;
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

	struct nk_context
	{
		nk_input input;
		nk_style style;
		nk_buffer memory;
		nk_clipboard clip;
		uint last_widget_state;
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

	struct nk_draw_vertex_layout_element
	{
		nk_draw_vertex_layout_attribute attribute;
		nk_draw_vertex_layout_format format;
		size_t offset;
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
		uint text_alignment;
		float border;
		float rounding;
		nk_vec2 padding;
		nk_vec2 image_padding;
		nk_vec2 touch_padding;
		nk_handle userdata;
		void function(nk_command_buffer*, nk_handle) draw_begin;
		void function(nk_command_buffer*, nk_handle) draw_end;
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
		uint text_alignment;
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
		uint text_alignment;
		float rounding;
		nk_vec2 padding;
		nk_vec2 touch_padding;
		nk_vec2 image_padding;
		nk_handle userdata;
		void function(nk_command_buffer*, nk_handle) draw_begin;
		void function(nk_command_buffer*, nk_handle) draw_end;
	}

	struct nk_style_slide;
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

	enum _Anonymous_0
	{
		nk_false = 0,
		nk_true = 1,
	}

	enum nk_false = _Anonymous_0.nk_false;
	enum nk_true = _Anonymous_0.nk_true;
	struct nk_color
	{
		ubyte r;
		ubyte g;
		ubyte b;
		ubyte a;
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

	alias nk_glyph = char[4];
	union nk_handle
	{
		void* ptr;
		int id;
	}

	struct nk_image
	{
		nk_handle handle;
		ushort w;
		ushort h;
		ushort[4] region;
	}

	struct nk_nine_slice
	{
		nk_image img;
		ushort l;
		ushort t;
		ushort r;
		ushort b;
	}

	struct nk_cursor
	{
		nk_image img;
		nk_vec2 size;
		nk_vec2 offset;
	}

	struct nk_scroll
	{
		uint x;
		uint y;
	}

	enum nk_heading
	{
		NK_UP = 0,
		NK_RIGHT = 1,
		NK_DOWN = 2,
		NK_LEFT = 3,
	}

	enum NK_UP = nk_heading.NK_UP;
	enum NK_RIGHT = nk_heading.NK_RIGHT;
	enum NK_DOWN = nk_heading.NK_DOWN;
	enum NK_LEFT = nk_heading.NK_LEFT;
	enum nk_button_behavior
	{
		NK_BUTTON_DEFAULT = 0,
		NK_BUTTON_REPEATER = 1,
	}

	enum NK_BUTTON_DEFAULT = nk_button_behavior.NK_BUTTON_DEFAULT;
	enum NK_BUTTON_REPEATER = nk_button_behavior.NK_BUTTON_REPEATER;
	enum nk_modify
	{
		NK_FIXED = 0,
		NK_MODIFIABLE = 1,
	}

	enum NK_FIXED = nk_modify.NK_FIXED;
	enum NK_MODIFIABLE = nk_modify.NK_MODIFIABLE;
	enum nk_orientation
	{
		NK_VERTICAL = 0,
		NK_HORIZONTAL = 1,
	}

	enum NK_VERTICAL = nk_orientation.NK_VERTICAL;
	enum NK_HORIZONTAL = nk_orientation.NK_HORIZONTAL;
	enum nk_collapse_states
	{
		NK_MINIMIZED = 0,
		NK_MAXIMIZED = 1,
	}

	enum NK_MINIMIZED = nk_collapse_states.NK_MINIMIZED;
	enum NK_MAXIMIZED = nk_collapse_states.NK_MAXIMIZED;
	enum nk_show_states
	{
		NK_HIDDEN = 0,
		NK_SHOWN = 1,
	}

	enum NK_HIDDEN = nk_show_states.NK_HIDDEN;
	enum NK_SHOWN = nk_show_states.NK_SHOWN;
	enum nk_chart_type
	{
		NK_CHART_LINES = 0,
		NK_CHART_COLUMN = 1,
		NK_CHART_MAX = 2,
	}

	enum NK_CHART_LINES = nk_chart_type.NK_CHART_LINES;
	enum NK_CHART_COLUMN = nk_chart_type.NK_CHART_COLUMN;
	enum NK_CHART_MAX = nk_chart_type.NK_CHART_MAX;
	enum nk_chart_event
	{
		NK_CHART_HOVERING = 1,
		NK_CHART_CLICKED = 2,
	}

	enum NK_CHART_HOVERING = nk_chart_event.NK_CHART_HOVERING;
	enum NK_CHART_CLICKED = nk_chart_event.NK_CHART_CLICKED;
	enum nk_color_format
	{
		NK_RGB = 0,
		NK_RGBA = 1,
	}

	enum NK_RGB = nk_color_format.NK_RGB;
	enum NK_RGBA = nk_color_format.NK_RGBA;
	enum nk_popup_type
	{
		NK_POPUP_STATIC = 0,
		NK_POPUP_DYNAMIC = 1,
	}

	enum NK_POPUP_STATIC = nk_popup_type.NK_POPUP_STATIC;
	enum NK_POPUP_DYNAMIC = nk_popup_type.NK_POPUP_DYNAMIC;
	enum nk_layout_format
	{
		NK_DYNAMIC = 0,
		NK_STATIC = 1,
	}

	enum NK_DYNAMIC = nk_layout_format.NK_DYNAMIC;
	enum NK_STATIC = nk_layout_format.NK_STATIC;
	enum nk_tree_type
	{
		NK_TREE_NODE = 0,
		NK_TREE_TAB = 1,
	}

	enum NK_TREE_NODE = nk_tree_type.NK_TREE_NODE;
	enum NK_TREE_TAB = nk_tree_type.NK_TREE_TAB;
	alias nk_plugin_alloc = void* function(nk_handle, void*, uint);
	alias nk_plugin_free = void function(nk_handle, void*);
	alias nk_plugin_filter = bool function(const(nk_text_edit)*, uint);
	alias nk_plugin_paste = void function(nk_handle, nk_text_edit*);
	alias nk_plugin_copy = void function(nk_handle, const(char)*, int);
	enum nk_symbol_type
	{
		NK_SYMBOL_NONE = 0,
		NK_SYMBOL_X = 1,
		NK_SYMBOL_UNDERSCORE = 2,
		NK_SYMBOL_CIRCLE_SOLID = 3,
		NK_SYMBOL_CIRCLE_OUTLINE = 4,
		NK_SYMBOL_RECT_SOLID = 5,
		NK_SYMBOL_RECT_OUTLINE = 6,
		NK_SYMBOL_TRIANGLE_UP = 7,
		NK_SYMBOL_TRIANGLE_DOWN = 8,
		NK_SYMBOL_TRIANGLE_LEFT = 9,
		NK_SYMBOL_TRIANGLE_RIGHT = 10,
		NK_SYMBOL_PLUS = 11,
		NK_SYMBOL_MINUS = 12,
		NK_SYMBOL_MAX = 13,
	}

	enum NK_SYMBOL_NONE = nk_symbol_type.NK_SYMBOL_NONE;
	enum NK_SYMBOL_X = nk_symbol_type.NK_SYMBOL_X;
	enum NK_SYMBOL_UNDERSCORE = nk_symbol_type.NK_SYMBOL_UNDERSCORE;
	enum NK_SYMBOL_CIRCLE_SOLID = nk_symbol_type.NK_SYMBOL_CIRCLE_SOLID;
	enum NK_SYMBOL_CIRCLE_OUTLINE = nk_symbol_type.NK_SYMBOL_CIRCLE_OUTLINE;
	enum NK_SYMBOL_RECT_SOLID = nk_symbol_type.NK_SYMBOL_RECT_SOLID;
	enum NK_SYMBOL_RECT_OUTLINE = nk_symbol_type.NK_SYMBOL_RECT_OUTLINE;
	enum NK_SYMBOL_TRIANGLE_UP = nk_symbol_type.NK_SYMBOL_TRIANGLE_UP;
	enum NK_SYMBOL_TRIANGLE_DOWN = nk_symbol_type.NK_SYMBOL_TRIANGLE_DOWN;
	enum NK_SYMBOL_TRIANGLE_LEFT = nk_symbol_type.NK_SYMBOL_TRIANGLE_LEFT;
	enum NK_SYMBOL_TRIANGLE_RIGHT = nk_symbol_type.NK_SYMBOL_TRIANGLE_RIGHT;
	enum NK_SYMBOL_PLUS = nk_symbol_type.NK_SYMBOL_PLUS;
	enum NK_SYMBOL_MINUS = nk_symbol_type.NK_SYMBOL_MINUS;
	enum NK_SYMBOL_MAX = nk_symbol_type.NK_SYMBOL_MAX;
	bool nk_init_default(nk_context*, const(nk_user_font)*) @nogc nothrow;
	bool nk_init_fixed(nk_context*, void*, size_t, const(nk_user_font)*) @nogc nothrow;
	bool nk_init(nk_context*, nk_allocator*, const(nk_user_font)*) @nogc nothrow;
	bool nk_init_custom(nk_context*, nk_buffer*, nk_buffer*, const(nk_user_font)*) @nogc nothrow;
	void nk_clear(nk_context*) @nogc nothrow;
	void nk_free(nk_context*) @nogc nothrow;
	enum nk_keys
	{
		NK_KEY_NONE = 0,
		NK_KEY_SHIFT = 1,
		NK_KEY_CTRL = 2,
		NK_KEY_DEL = 3,
		NK_KEY_ENTER = 4,
		NK_KEY_TAB = 5,
		NK_KEY_BACKSPACE = 6,
		NK_KEY_COPY = 7,
		NK_KEY_CUT = 8,
		NK_KEY_PASTE = 9,
		NK_KEY_UP = 10,
		NK_KEY_DOWN = 11,
		NK_KEY_LEFT = 12,
		NK_KEY_RIGHT = 13,
		NK_KEY_TEXT_INSERT_MODE = 14,
		NK_KEY_TEXT_REPLACE_MODE = 15,
		NK_KEY_TEXT_RESET_MODE = 16,
		NK_KEY_TEXT_LINE_START = 17,
		NK_KEY_TEXT_LINE_END = 18,
		NK_KEY_TEXT_START = 19,
		NK_KEY_TEXT_END = 20,
		NK_KEY_TEXT_UNDO = 21,
		NK_KEY_TEXT_REDO = 22,
		NK_KEY_TEXT_SELECT_ALL = 23,
		NK_KEY_TEXT_WORD_LEFT = 24,
		NK_KEY_TEXT_WORD_RIGHT = 25,
		NK_KEY_SCROLL_START = 26,
		NK_KEY_SCROLL_END = 27,
		NK_KEY_SCROLL_DOWN = 28,
		NK_KEY_SCROLL_UP = 29,
		NK_KEY_MAX = 30,
	}

	enum NK_KEY_NONE = nk_keys.NK_KEY_NONE;
	enum NK_KEY_SHIFT = nk_keys.NK_KEY_SHIFT;
	enum NK_KEY_CTRL = nk_keys.NK_KEY_CTRL;
	enum NK_KEY_DEL = nk_keys.NK_KEY_DEL;
	enum NK_KEY_ENTER = nk_keys.NK_KEY_ENTER;
	enum NK_KEY_TAB = nk_keys.NK_KEY_TAB;
	enum NK_KEY_BACKSPACE = nk_keys.NK_KEY_BACKSPACE;
	enum NK_KEY_COPY = nk_keys.NK_KEY_COPY;
	enum NK_KEY_CUT = nk_keys.NK_KEY_CUT;
	enum NK_KEY_PASTE = nk_keys.NK_KEY_PASTE;
	enum NK_KEY_UP = nk_keys.NK_KEY_UP;
	enum NK_KEY_DOWN = nk_keys.NK_KEY_DOWN;
	enum NK_KEY_LEFT = nk_keys.NK_KEY_LEFT;
	enum NK_KEY_RIGHT = nk_keys.NK_KEY_RIGHT;
	enum NK_KEY_TEXT_INSERT_MODE = nk_keys.NK_KEY_TEXT_INSERT_MODE;
	enum NK_KEY_TEXT_REPLACE_MODE = nk_keys.NK_KEY_TEXT_REPLACE_MODE;
	enum NK_KEY_TEXT_RESET_MODE = nk_keys.NK_KEY_TEXT_RESET_MODE;
	enum NK_KEY_TEXT_LINE_START = nk_keys.NK_KEY_TEXT_LINE_START;
	enum NK_KEY_TEXT_LINE_END = nk_keys.NK_KEY_TEXT_LINE_END;
	enum NK_KEY_TEXT_START = nk_keys.NK_KEY_TEXT_START;
	enum NK_KEY_TEXT_END = nk_keys.NK_KEY_TEXT_END;
	enum NK_KEY_TEXT_UNDO = nk_keys.NK_KEY_TEXT_UNDO;
	enum NK_KEY_TEXT_REDO = nk_keys.NK_KEY_TEXT_REDO;
	enum NK_KEY_TEXT_SELECT_ALL = nk_keys.NK_KEY_TEXT_SELECT_ALL;
	enum NK_KEY_TEXT_WORD_LEFT = nk_keys.NK_KEY_TEXT_WORD_LEFT;
	enum NK_KEY_TEXT_WORD_RIGHT = nk_keys.NK_KEY_TEXT_WORD_RIGHT;
	enum NK_KEY_SCROLL_START = nk_keys.NK_KEY_SCROLL_START;
	enum NK_KEY_SCROLL_END = nk_keys.NK_KEY_SCROLL_END;
	enum NK_KEY_SCROLL_DOWN = nk_keys.NK_KEY_SCROLL_DOWN;
	enum NK_KEY_SCROLL_UP = nk_keys.NK_KEY_SCROLL_UP;
	enum NK_KEY_MAX = nk_keys.NK_KEY_MAX;
	enum nk_buttons
	{
		NK_BUTTON_LEFT = 0,
		NK_BUTTON_MIDDLE = 1,
		NK_BUTTON_RIGHT = 2,
		NK_BUTTON_DOUBLE = 3,
		NK_BUTTON_MAX = 4,
	}

	enum NK_BUTTON_LEFT = nk_buttons.NK_BUTTON_LEFT;
	enum NK_BUTTON_MIDDLE = nk_buttons.NK_BUTTON_MIDDLE;
	enum NK_BUTTON_RIGHT = nk_buttons.NK_BUTTON_RIGHT;
	enum NK_BUTTON_DOUBLE = nk_buttons.NK_BUTTON_DOUBLE;
	enum NK_BUTTON_MAX = nk_buttons.NK_BUTTON_MAX;
	void nk_input_begin(nk_context*) @nogc nothrow;
	void nk_input_motion(nk_context*, int, int) @nogc nothrow;
	void nk_input_key(nk_context*, nk_keys, bool) @nogc nothrow;
	void nk_input_button(nk_context*, nk_buttons, int, int, bool) @nogc nothrow;
	void nk_input_scroll(nk_context*, nk_vec2) @nogc nothrow;
	void nk_input_char(nk_context*, char) @nogc nothrow;
	void nk_input_glyph(nk_context*, const(char*)) @nogc nothrow;
	void nk_input_unicode(nk_context*, uint) @nogc nothrow;
	void nk_input_end(nk_context*) @nogc nothrow;
	enum nk_anti_aliasing
	{
		NK_ANTI_ALIASING_OFF = 0,
		NK_ANTI_ALIASING_ON = 1,
	}

	enum NK_ANTI_ALIASING_OFF = nk_anti_aliasing.NK_ANTI_ALIASING_OFF;
	enum NK_ANTI_ALIASING_ON = nk_anti_aliasing.NK_ANTI_ALIASING_ON;
	enum nk_convert_result
	{
		NK_CONVERT_SUCCESS = 0,
		NK_CONVERT_INVALID_PARAM = 1,
		NK_CONVERT_COMMAND_BUFFER_FULL = 2,
		NK_CONVERT_VERTEX_BUFFER_FULL = 4,
		NK_CONVERT_ELEMENT_BUFFER_FULL = 8,
	}

	enum NK_CONVERT_SUCCESS = nk_convert_result.NK_CONVERT_SUCCESS;
	enum NK_CONVERT_INVALID_PARAM = nk_convert_result.NK_CONVERT_INVALID_PARAM;
	enum NK_CONVERT_COMMAND_BUFFER_FULL = nk_convert_result.NK_CONVERT_COMMAND_BUFFER_FULL;
	enum NK_CONVERT_VERTEX_BUFFER_FULL = nk_convert_result.NK_CONVERT_VERTEX_BUFFER_FULL;
	enum NK_CONVERT_ELEMENT_BUFFER_FULL = nk_convert_result.NK_CONVERT_ELEMENT_BUFFER_FULL;
	struct nk_draw_null_texture
	{
		nk_handle texture;
		nk_vec2 uv;
	}

	const(nk_command)* nk__begin(nk_context*) @nogc nothrow;
	struct nk_command
	{
		nk_command_type type;
		size_t next;
	}

	const(nk_command)* nk__next(nk_context*, const(nk_command)*) @nogc nothrow;
	bool nk_filter_default(const(nk_text_edit)*, uint) @nogc nothrow;
	uint nk_convert(nk_context*, nk_buffer*, nk_buffer*, nk_buffer*, const(nk_convert_config)*) @nogc nothrow;
	const(nk_draw_command)* nk__draw_begin(const(nk_context)*, const(nk_buffer)*) @nogc nothrow;
	const(nk_draw_command)* nk__draw_end(const(nk_context)*, const(nk_buffer)*) @nogc nothrow;
	const(nk_draw_command)* nk__draw_next(const(nk_draw_command)*, const(nk_buffer)*, const(nk_context)*) @nogc nothrow;
	enum nk_panel_flags
	{
		NK_WINDOW_BORDER = 1,
		NK_WINDOW_MOVABLE = 2,
		NK_WINDOW_SCALABLE = 4,
		NK_WINDOW_CLOSABLE = 8,
		NK_WINDOW_MINIMIZABLE = 16,
		NK_WINDOW_NO_SCROLLBAR = 32,
		NK_WINDOW_TITLE = 64,
		NK_WINDOW_SCROLL_AUTO_HIDE = 128,
		NK_WINDOW_BACKGROUND = 256,
		NK_WINDOW_SCALE_LEFT = 512,
		NK_WINDOW_NO_INPUT = 1024,
	}

	enum NK_WINDOW_BORDER = nk_panel_flags.NK_WINDOW_BORDER;
	enum NK_WINDOW_MOVABLE = nk_panel_flags.NK_WINDOW_MOVABLE;
	enum NK_WINDOW_SCALABLE = nk_panel_flags.NK_WINDOW_SCALABLE;
	enum NK_WINDOW_CLOSABLE = nk_panel_flags.NK_WINDOW_CLOSABLE;
	enum NK_WINDOW_MINIMIZABLE = nk_panel_flags.NK_WINDOW_MINIMIZABLE;
	enum NK_WINDOW_NO_SCROLLBAR = nk_panel_flags.NK_WINDOW_NO_SCROLLBAR;
	enum NK_WINDOW_TITLE = nk_panel_flags.NK_WINDOW_TITLE;
	enum NK_WINDOW_SCROLL_AUTO_HIDE = nk_panel_flags.NK_WINDOW_SCROLL_AUTO_HIDE;
	enum NK_WINDOW_BACKGROUND = nk_panel_flags.NK_WINDOW_BACKGROUND;
	enum NK_WINDOW_SCALE_LEFT = nk_panel_flags.NK_WINDOW_SCALE_LEFT;
	enum NK_WINDOW_NO_INPUT = nk_panel_flags.NK_WINDOW_NO_INPUT;
	bool nk_begin(nk_context*, const(char)*, nk_rect, uint) @nogc nothrow;
	bool nk_begin_titled(nk_context*, const(char)*, const(char)*, nk_rect, uint) @nogc nothrow;
	void nk_end(nk_context*) @nogc nothrow;
	struct nk_window
	{
		uint seq;
		uint name;
		char[64] name_string;
		uint flags;
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

	nk_window* nk_window_find(nk_context*, const(char)*) @nogc nothrow;
	nk_rect nk_window_get_bounds(const(nk_context)*) @nogc nothrow;
	nk_vec2 nk_window_get_position(const(nk_context)*) @nogc nothrow;
	nk_vec2 nk_window_get_size(const(nk_context)*) @nogc nothrow;
	float nk_window_get_width(const(nk_context)*) @nogc nothrow;
	float nk_window_get_height(const(nk_context)*) @nogc nothrow;
	nk_panel* nk_window_get_panel(nk_context*) @nogc nothrow;
	nk_rect nk_window_get_content_region(nk_context*) @nogc nothrow;
	nk_vec2 nk_window_get_content_region_min(nk_context*) @nogc nothrow;
	nk_vec2 nk_window_get_content_region_max(nk_context*) @nogc nothrow;
	nk_vec2 nk_window_get_content_region_size(nk_context*) @nogc nothrow;
	nk_command_buffer* nk_window_get_canvas(nk_context*) @nogc nothrow;
	void nk_window_get_scroll(nk_context*, uint*, uint*) @nogc nothrow;
	bool nk_window_has_focus(const(nk_context)*) @nogc nothrow;
	bool nk_window_is_hovered(nk_context*) @nogc nothrow;
	bool nk_window_is_collapsed(nk_context*, const(char)*) @nogc nothrow;
	bool nk_window_is_closed(nk_context*, const(char)*) @nogc nothrow;
	bool nk_window_is_hidden(nk_context*, const(char)*) @nogc nothrow;
	bool nk_window_is_active(nk_context*, const(char)*) @nogc nothrow;
	bool nk_window_is_any_hovered(nk_context*) @nogc nothrow;
	bool nk_item_is_any_active(nk_context*) @nogc nothrow;
	void nk_window_set_bounds(nk_context*, const(char)*, nk_rect) @nogc nothrow;
	void nk_window_set_position(nk_context*, const(char)*, nk_vec2) @nogc nothrow;
	void nk_window_set_size(nk_context*, const(char)*, nk_vec2) @nogc nothrow;
	void nk_window_set_focus(nk_context*, const(char)*) @nogc nothrow;
	void nk_window_set_scroll(nk_context*, uint, uint) @nogc nothrow;
	void nk_window_close(nk_context*, const(char)*) @nogc nothrow;
	void nk_window_collapse(nk_context*, const(char)*, nk_collapse_states) @nogc nothrow;
	void nk_window_collapse_if(nk_context*, const(char)*, nk_collapse_states, int) @nogc nothrow;
	void nk_window_show(nk_context*, const(char)*, nk_show_states) @nogc nothrow;
	void nk_window_show_if(nk_context*, const(char)*, nk_show_states, int) @nogc nothrow;
	void nk_layout_set_min_row_height(nk_context*, float) @nogc nothrow;
	void nk_layout_reset_min_row_height(nk_context*) @nogc nothrow;
	nk_rect nk_layout_widget_bounds(nk_context*) @nogc nothrow;
	float nk_layout_ratio_from_pixel(nk_context*, float) @nogc nothrow;
	void nk_layout_row_dynamic(nk_context*, float, int) @nogc nothrow;
	void nk_layout_row_static(nk_context*, float, int, int) @nogc nothrow;
	void nk_layout_row_begin(nk_context*, nk_layout_format, float, int) @nogc nothrow;
	void nk_layout_row_push(nk_context*, float) @nogc nothrow;
	void nk_layout_row_end(nk_context*) @nogc nothrow;
	void nk_layout_row(nk_context*, nk_layout_format, float, int, const(float)*) @nogc nothrow;
	void nk_layout_row_template_begin(nk_context*, float) @nogc nothrow;
	void nk_layout_row_template_push_dynamic(nk_context*) @nogc nothrow;
	void nk_layout_row_template_push_variable(nk_context*, float) @nogc nothrow;
	void nk_layout_row_template_push_static(nk_context*, float) @nogc nothrow;
	void nk_layout_row_template_end(nk_context*) @nogc nothrow;
	void nk_layout_space_begin(nk_context*, nk_layout_format, float, int) @nogc nothrow;
	void nk_layout_space_push(nk_context*, nk_rect) @nogc nothrow;
	void nk_layout_space_end(nk_context*) @nogc nothrow;
	nk_rect nk_layout_space_bounds(nk_context*) @nogc nothrow;
	nk_vec2 nk_layout_space_to_screen(nk_context*, nk_vec2) @nogc nothrow;
	nk_vec2 nk_layout_space_to_local(nk_context*, nk_vec2) @nogc nothrow;
	nk_rect nk_layout_space_rect_to_screen(nk_context*, nk_rect) @nogc nothrow;
	nk_rect nk_layout_space_rect_to_local(nk_context*, nk_rect) @nogc nothrow;
	void nk_spacer(nk_context*) @nogc nothrow;
	bool nk_group_begin(nk_context*, const(char)*, uint) @nogc nothrow;
	bool nk_group_begin_titled(nk_context*, const(char)*, const(char)*, uint) @nogc nothrow;
	void nk_group_end(nk_context*) @nogc nothrow;
	bool nk_group_scrolled_offset_begin(nk_context*, uint*, uint*, const(char)*, uint) @nogc nothrow;
	bool nk_group_scrolled_begin(nk_context*, nk_scroll*, const(char)*, uint) @nogc nothrow;
	void nk_group_scrolled_end(nk_context*) @nogc nothrow;
	void nk_group_get_scroll(nk_context*, const(char)*, uint*, uint*) @nogc nothrow;
	void nk_group_set_scroll(nk_context*, const(char)*, uint, uint) @nogc nothrow;
	enum nk_text_edit_mode
	{
		NK_TEXT_EDIT_MODE_VIEW = 0,
		NK_TEXT_EDIT_MODE_INSERT = 1,
		NK_TEXT_EDIT_MODE_REPLACE = 2,
	}

	enum NK_TEXT_EDIT_MODE_VIEW = nk_text_edit_mode.NK_TEXT_EDIT_MODE_VIEW;
	enum NK_TEXT_EDIT_MODE_INSERT = nk_text_edit_mode.NK_TEXT_EDIT_MODE_INSERT;
	enum NK_TEXT_EDIT_MODE_REPLACE = nk_text_edit_mode.NK_TEXT_EDIT_MODE_REPLACE;
	enum nk_text_edit_type
	{
		NK_TEXT_EDIT_SINGLE_LINE = 0,
		NK_TEXT_EDIT_MULTI_LINE = 1,
	}

	enum NK_TEXT_EDIT_SINGLE_LINE = nk_text_edit_type.NK_TEXT_EDIT_SINGLE_LINE;
	enum NK_TEXT_EDIT_MULTI_LINE = nk_text_edit_type.NK_TEXT_EDIT_MULTI_LINE;
	bool nk_tree_push_hashed(nk_context*, nk_tree_type, const(char)*, nk_collapse_states, const(char)*, int, int) @nogc nothrow;
	bool nk_tree_image_push_hashed(nk_context*, nk_tree_type, nk_image, const(char)*, nk_collapse_states, const(char)*, int, int) @nogc nothrow;
	void nk_tree_pop(nk_context*) @nogc nothrow;
	bool nk_tree_state_push(nk_context*, nk_tree_type, const(char)*, nk_collapse_states*) @nogc nothrow;
	bool nk_tree_state_image_push(nk_context*, nk_tree_type, nk_image, const(char)*, nk_collapse_states*) @nogc nothrow;
	void nk_tree_state_pop(nk_context*) @nogc nothrow;
	struct nk_text_undo_state
	{
		nk_text_undo_record[99] undo_rec;
		uint[999] undo_char;
		short undo_point;
		short redo_point;
		short undo_char_point;
		short redo_char_point;
	}

	struct nk_text_undo_record
	{
		int where;
		short insert_length;
		short delete_length;
		short char_storage;
	}

	bool nk_tree_element_push_hashed(nk_context*, nk_tree_type, const(char)*, nk_collapse_states, bool*, const(char)*, int, int) @nogc nothrow;
	bool nk_tree_element_image_push_hashed(nk_context*, nk_tree_type, nk_image, const(char)*, nk_collapse_states,
			bool*, const(char)*, int, int) @nogc nothrow;
	void nk_tree_element_pop(nk_context*) @nogc nothrow;
	struct nk_list_view
	{
		int begin;
		int end;
		int count;
		int total_height;
		nk_context* ctx;
		uint* scroll_pointer;
		uint scroll_value;
	}

	bool nk_list_view_begin(nk_context*, nk_list_view*, const(char)*, uint, int, int) @nogc nothrow;
	void nk_list_view_end(nk_list_view*) @nogc nothrow;
	enum nk_widget_layout_states
	{
		NK_WIDGET_INVALID = 0,
		NK_WIDGET_VALID = 1,
		NK_WIDGET_ROM = 2,
	}

	enum NK_WIDGET_INVALID = nk_widget_layout_states.NK_WIDGET_INVALID;
	enum NK_WIDGET_VALID = nk_widget_layout_states.NK_WIDGET_VALID;
	enum NK_WIDGET_ROM = nk_widget_layout_states.NK_WIDGET_ROM;
	enum nk_widget_states
	{
		NK_WIDGET_STATE_MODIFIED = 2,
		NK_WIDGET_STATE_INACTIVE = 4,
		NK_WIDGET_STATE_ENTERED = 8,
		NK_WIDGET_STATE_HOVER = 16,
		NK_WIDGET_STATE_ACTIVED = 32,
		NK_WIDGET_STATE_LEFT = 64,
		NK_WIDGET_STATE_HOVERED = 18,
		NK_WIDGET_STATE_ACTIVE = 34,
	}

	enum NK_WIDGET_STATE_MODIFIED = nk_widget_states.NK_WIDGET_STATE_MODIFIED;
	enum NK_WIDGET_STATE_INACTIVE = nk_widget_states.NK_WIDGET_STATE_INACTIVE;
	enum NK_WIDGET_STATE_ENTERED = nk_widget_states.NK_WIDGET_STATE_ENTERED;
	enum NK_WIDGET_STATE_HOVER = nk_widget_states.NK_WIDGET_STATE_HOVER;
	enum NK_WIDGET_STATE_ACTIVED = nk_widget_states.NK_WIDGET_STATE_ACTIVED;
	enum NK_WIDGET_STATE_LEFT = nk_widget_states.NK_WIDGET_STATE_LEFT;
	enum NK_WIDGET_STATE_HOVERED = nk_widget_states.NK_WIDGET_STATE_HOVERED;
	enum NK_WIDGET_STATE_ACTIVE = nk_widget_states.NK_WIDGET_STATE_ACTIVE;
	nk_widget_layout_states nk_widget(nk_rect*, const(nk_context)*) @nogc nothrow;
	nk_widget_layout_states nk_widget_fitting(nk_rect*, nk_context*, nk_vec2) @nogc nothrow;
	nk_rect nk_widget_bounds(nk_context*) @nogc nothrow;
	nk_vec2 nk_widget_position(nk_context*) @nogc nothrow;
	nk_vec2 nk_widget_size(nk_context*) @nogc nothrow;
	float nk_widget_width(nk_context*) @nogc nothrow;
	float nk_widget_height(nk_context*) @nogc nothrow;
	bool nk_widget_is_hovered(nk_context*) @nogc nothrow;
	bool nk_widget_is_mouse_clicked(nk_context*, nk_buttons) @nogc nothrow;
	bool nk_widget_has_mouse_click_down(nk_context*, nk_buttons, bool) @nogc nothrow;
	void nk_spacing(nk_context*, int) @nogc nothrow;
	enum nk_text_align
	{
		NK_TEXT_ALIGN_LEFT = 1,
		NK_TEXT_ALIGN_CENTERED = 2,
		NK_TEXT_ALIGN_RIGHT = 4,
		NK_TEXT_ALIGN_TOP = 8,
		NK_TEXT_ALIGN_MIDDLE = 16,
		NK_TEXT_ALIGN_BOTTOM = 32,
	}

	enum NK_TEXT_ALIGN_LEFT = nk_text_align.NK_TEXT_ALIGN_LEFT;
	enum NK_TEXT_ALIGN_CENTERED = nk_text_align.NK_TEXT_ALIGN_CENTERED;
	enum NK_TEXT_ALIGN_RIGHT = nk_text_align.NK_TEXT_ALIGN_RIGHT;
	enum NK_TEXT_ALIGN_TOP = nk_text_align.NK_TEXT_ALIGN_TOP;
	enum NK_TEXT_ALIGN_MIDDLE = nk_text_align.NK_TEXT_ALIGN_MIDDLE;
	enum NK_TEXT_ALIGN_BOTTOM = nk_text_align.NK_TEXT_ALIGN_BOTTOM;
	enum nk_text_alignment
	{
		NK_TEXT_LEFT = 17,
		NK_TEXT_CENTERED = 18,
		NK_TEXT_RIGHT = 20,
	}

	enum NK_TEXT_LEFT = nk_text_alignment.NK_TEXT_LEFT;
	enum NK_TEXT_CENTERED = nk_text_alignment.NK_TEXT_CENTERED;
	enum NK_TEXT_RIGHT = nk_text_alignment.NK_TEXT_RIGHT;
	void nk_text(nk_context*, const(char)*, int, uint) @nogc nothrow;
	void nk_text_colored(nk_context*, const(char)*, int, uint, nk_color) @nogc nothrow;
	void nk_text_wrap(nk_context*, const(char)*, int) @nogc nothrow;
	void nk_text_wrap_colored(nk_context*, const(char)*, int, nk_color) @nogc nothrow;
	void nk_label(nk_context*, const(char)*, uint) @nogc nothrow;
	void nk_label_colored(nk_context*, const(char)*, uint, nk_color) @nogc nothrow;
	void nk_label_wrap(nk_context*, const(char)*) @nogc nothrow;
	void nk_label_colored_wrap(nk_context*, const(char)*, nk_color) @nogc nothrow;
	pragma(mangle, "nk_image") void nk_image_(nk_context*, nk_image) @nogc nothrow;
	void nk_image_color(nk_context*, nk_image, nk_color) @nogc nothrow;
	void nk_labelf(nk_context*, uint, const(char)*, ...) @nogc nothrow;
	void nk_labelf_colored(nk_context*, uint, nk_color, const(char)*, ...) @nogc nothrow;
	void nk_labelf_wrap(nk_context*, const(char)*, ...) @nogc nothrow;
	void nk_labelf_colored_wrap(nk_context*, nk_color, const(char)*, ...) @nogc nothrow;
	void nk_labelfv(nk_context*, uint, const(char)*, char*) @nogc nothrow;
	void nk_labelfv_colored(nk_context*, uint, nk_color, const(char)*, char*) @nogc nothrow;
	void nk_labelfv_wrap(nk_context*, const(char)*, char*) @nogc nothrow;
	void nk_labelfv_colored_wrap(nk_context*, nk_color, const(char)*, char*) @nogc nothrow;
	void nk_value_bool(nk_context*, const(char)*, int) @nogc nothrow;
	void nk_value_int(nk_context*, const(char)*, int) @nogc nothrow;
	void nk_value_uint(nk_context*, const(char)*, uint) @nogc nothrow;
	void nk_value_float(nk_context*, const(char)*, float) @nogc nothrow;
	void nk_value_color_byte(nk_context*, const(char)*, nk_color) @nogc nothrow;
	void nk_value_color_float(nk_context*, const(char)*, nk_color) @nogc nothrow;
	void nk_value_color_hex(nk_context*, const(char)*, nk_color) @nogc nothrow;
	bool nk_button_text(nk_context*, const(char)*, int) @nogc nothrow;
	bool nk_button_label(nk_context*, const(char)*) @nogc nothrow;
	bool nk_button_color(nk_context*, nk_color) @nogc nothrow;
	bool nk_button_symbol(nk_context*, nk_symbol_type) @nogc nothrow;
	bool nk_button_image(nk_context*, nk_image) @nogc nothrow;
	bool nk_button_symbol_label(nk_context*, nk_symbol_type, const(char)*, uint) @nogc nothrow;
	bool nk_button_symbol_text(nk_context*, nk_symbol_type, const(char)*, int, uint) @nogc nothrow;
	bool nk_button_image_label(nk_context*, nk_image, const(char)*, uint) @nogc nothrow;
	bool nk_button_image_text(nk_context*, nk_image, const(char)*, int, uint) @nogc nothrow;
	bool nk_button_text_styled(nk_context*, const(nk_style_button)*, const(char)*, int) @nogc nothrow;
	bool nk_button_label_styled(nk_context*, const(nk_style_button)*, const(char)*) @nogc nothrow;
	bool nk_button_symbol_styled(nk_context*, const(nk_style_button)*, nk_symbol_type) @nogc nothrow;
	bool nk_button_image_styled(nk_context*, const(nk_style_button)*, nk_image) @nogc nothrow;
	bool nk_button_symbol_text_styled(nk_context*, const(nk_style_button)*, nk_symbol_type, const(char)*, int, uint) @nogc nothrow;
	bool nk_button_symbol_label_styled(nk_context*, const(nk_style_button)*, nk_symbol_type, const(char)*, uint) @nogc nothrow;
	bool nk_button_image_label_styled(nk_context*, const(nk_style_button)*, nk_image, const(char)*, uint) @nogc nothrow;
	bool nk_button_image_text_styled(nk_context*, const(nk_style_button)*, nk_image, const(char)*, int, uint) @nogc nothrow;
	void nk_button_set_behavior(nk_context*, nk_button_behavior) @nogc nothrow;
	bool nk_button_push_behavior(nk_context*, nk_button_behavior) @nogc nothrow;
	bool nk_button_pop_behavior(nk_context*) @nogc nothrow;
	bool nk_check_label(nk_context*, const(char)*, bool) @nogc nothrow;
	bool nk_check_text(nk_context*, const(char)*, int, bool) @nogc nothrow;
	uint nk_check_flags_label(nk_context*, const(char)*, uint, uint) @nogc nothrow;
	uint nk_check_flags_text(nk_context*, const(char)*, int, uint, uint) @nogc nothrow;
	bool nk_checkbox_label(nk_context*, const(char)*, bool*) @nogc nothrow;
	bool nk_checkbox_text(nk_context*, const(char)*, int, bool*) @nogc nothrow;
	bool nk_checkbox_flags_label(nk_context*, const(char)*, uint*, uint) @nogc nothrow;
	bool nk_checkbox_flags_text(nk_context*, const(char)*, int, uint*, uint) @nogc nothrow;
	bool nk_radio_label(nk_context*, const(char)*, bool*) @nogc nothrow;
	bool nk_radio_text(nk_context*, const(char)*, int, bool*) @nogc nothrow;
	bool nk_option_label(nk_context*, const(char)*, bool) @nogc nothrow;
	bool nk_option_text(nk_context*, const(char)*, int, bool) @nogc nothrow;
	bool nk_selectable_label(nk_context*, const(char)*, uint, bool*) @nogc nothrow;
	bool nk_selectable_text(nk_context*, const(char)*, int, uint, bool*) @nogc nothrow;
	bool nk_selectable_image_label(nk_context*, nk_image, const(char)*, uint, bool*) @nogc nothrow;
	bool nk_selectable_image_text(nk_context*, nk_image, const(char)*, int, uint, bool*) @nogc nothrow;
	bool nk_selectable_symbol_label(nk_context*, nk_symbol_type, const(char)*, uint, bool*) @nogc nothrow;
	bool nk_selectable_symbol_text(nk_context*, nk_symbol_type, const(char)*, int, uint, bool*) @nogc nothrow;
	bool nk_select_label(nk_context*, const(char)*, uint, bool) @nogc nothrow;
	bool nk_select_text(nk_context*, const(char)*, int, uint, bool) @nogc nothrow;
	bool nk_select_image_label(nk_context*, nk_image, const(char)*, uint, bool) @nogc nothrow;
	bool nk_select_image_text(nk_context*, nk_image, const(char)*, int, uint, bool) @nogc nothrow;
	bool nk_select_symbol_label(nk_context*, nk_symbol_type, const(char)*, uint, bool) @nogc nothrow;
	bool nk_select_symbol_text(nk_context*, nk_symbol_type, const(char)*, int, uint, bool) @nogc nothrow;
	float nk_slide_float(nk_context*, float, float, float, float) @nogc nothrow;
	int nk_slide_int(nk_context*, int, int, int, int) @nogc nothrow;
	bool nk_slider_float(nk_context*, float, float*, float, float) @nogc nothrow;
	bool nk_slider_int(nk_context*, int, int*, int, int) @nogc nothrow;
	bool nk_progress(nk_context*, size_t*, size_t, bool) @nogc nothrow;
	size_t nk_prog(nk_context*, size_t, size_t, bool) @nogc nothrow;
	nk_colorf nk_color_picker(nk_context*, nk_colorf, nk_color_format) @nogc nothrow;
	bool nk_color_pick(nk_context*, nk_colorf*, nk_color_format) @nogc nothrow;
	void nk_property_int(nk_context*, const(char)*, int, int*, int, int, float) @nogc nothrow;
	void nk_property_float(nk_context*, const(char)*, float, float*, float, float, float) @nogc nothrow;
	void nk_property_double(nk_context*, const(char)*, double, double*, double, double, float) @nogc nothrow;
	int nk_propertyi(nk_context*, const(char)*, int, int, int, int, float) @nogc nothrow;
	float nk_propertyf(nk_context*, const(char)*, float, float, float, float, float) @nogc nothrow;
	double nk_propertyd(nk_context*, const(char)*, double, double, double, double, float) @nogc nothrow;
	enum nk_edit_flags
	{
		NK_EDIT_DEFAULT = 0,
		NK_EDIT_READ_ONLY = 1,
		NK_EDIT_AUTO_SELECT = 2,
		NK_EDIT_SIG_ENTER = 4,
		NK_EDIT_ALLOW_TAB = 8,
		NK_EDIT_NO_CURSOR = 16,
		NK_EDIT_SELECTABLE = 32,
		NK_EDIT_CLIPBOARD = 64,
		NK_EDIT_CTRL_ENTER_NEWLINE = 128,
		NK_EDIT_NO_HORIZONTAL_SCROLL = 256,
		NK_EDIT_ALWAYS_INSERT_MODE = 512,
		NK_EDIT_MULTILINE = 1024,
		NK_EDIT_GOTO_END_ON_ACTIVATE = 2048,
	}

	enum NK_EDIT_DEFAULT = nk_edit_flags.NK_EDIT_DEFAULT;
	enum NK_EDIT_READ_ONLY = nk_edit_flags.NK_EDIT_READ_ONLY;
	enum NK_EDIT_AUTO_SELECT = nk_edit_flags.NK_EDIT_AUTO_SELECT;
	enum NK_EDIT_SIG_ENTER = nk_edit_flags.NK_EDIT_SIG_ENTER;
	enum NK_EDIT_ALLOW_TAB = nk_edit_flags.NK_EDIT_ALLOW_TAB;
	enum NK_EDIT_NO_CURSOR = nk_edit_flags.NK_EDIT_NO_CURSOR;
	enum NK_EDIT_SELECTABLE = nk_edit_flags.NK_EDIT_SELECTABLE;
	enum NK_EDIT_CLIPBOARD = nk_edit_flags.NK_EDIT_CLIPBOARD;
	enum NK_EDIT_CTRL_ENTER_NEWLINE = nk_edit_flags.NK_EDIT_CTRL_ENTER_NEWLINE;
	enum NK_EDIT_NO_HORIZONTAL_SCROLL = nk_edit_flags.NK_EDIT_NO_HORIZONTAL_SCROLL;
	enum NK_EDIT_ALWAYS_INSERT_MODE = nk_edit_flags.NK_EDIT_ALWAYS_INSERT_MODE;
	enum NK_EDIT_MULTILINE = nk_edit_flags.NK_EDIT_MULTILINE;
	enum NK_EDIT_GOTO_END_ON_ACTIVATE = nk_edit_flags.NK_EDIT_GOTO_END_ON_ACTIVATE;
	enum nk_edit_types
	{
		NK_EDIT_SIMPLE = 512,
		NK_EDIT_FIELD = 608,
		NK_EDIT_BOX = 1640,
		NK_EDIT_EDITOR = 1128,
	}

	enum NK_EDIT_SIMPLE = nk_edit_types.NK_EDIT_SIMPLE;
	enum NK_EDIT_FIELD = nk_edit_types.NK_EDIT_FIELD;
	enum NK_EDIT_BOX = nk_edit_types.NK_EDIT_BOX;
	enum NK_EDIT_EDITOR = nk_edit_types.NK_EDIT_EDITOR;
	enum nk_edit_events
	{
		NK_EDIT_ACTIVE = 1,
		NK_EDIT_INACTIVE = 2,
		NK_EDIT_ACTIVATED = 4,
		NK_EDIT_DEACTIVATED = 8,
		NK_EDIT_COMMITED = 16,
	}

	enum NK_EDIT_ACTIVE = nk_edit_events.NK_EDIT_ACTIVE;
	enum NK_EDIT_INACTIVE = nk_edit_events.NK_EDIT_INACTIVE;
	enum NK_EDIT_ACTIVATED = nk_edit_events.NK_EDIT_ACTIVATED;
	enum NK_EDIT_DEACTIVATED = nk_edit_events.NK_EDIT_DEACTIVATED;
	enum NK_EDIT_COMMITED = nk_edit_events.NK_EDIT_COMMITED;
	uint nk_edit_string(nk_context*, uint, char*, int*, int, bool function(const(nk_text_edit)*, uint)) @nogc nothrow;
	uint nk_edit_string_zero_terminated(nk_context*, uint, char*, int, bool function(const(nk_text_edit)*, uint)) @nogc nothrow;
	uint nk_edit_buffer(nk_context*, uint, nk_text_edit*, bool function(const(nk_text_edit)*, uint)) @nogc nothrow;
	void nk_edit_focus(nk_context*, uint) @nogc nothrow;
	void nk_edit_unfocus(nk_context*) @nogc nothrow;
	bool nk_chart_begin(nk_context*, nk_chart_type, int, float, float) @nogc nothrow;
	bool nk_chart_begin_colored(nk_context*, nk_chart_type, nk_color, nk_color, int, float, float) @nogc nothrow;
	void nk_chart_add_slot(nk_context*, const(nk_chart_type), int, float, float) @nogc nothrow;
	void nk_chart_add_slot_colored(nk_context*, const(nk_chart_type), nk_color, nk_color, int, float, float) @nogc nothrow;
	uint nk_chart_push(nk_context*, float) @nogc nothrow;
	uint nk_chart_push_slot(nk_context*, float, int) @nogc nothrow;
	void nk_chart_end(nk_context*) @nogc nothrow;
	void nk_plot(nk_context*, nk_chart_type, const(float)*, int, int) @nogc nothrow;
	void nk_plot_function(nk_context*, nk_chart_type, void*, float function(void*, int), int, int) @nogc nothrow;
	bool nk_popup_begin(nk_context*, nk_popup_type, const(char)*, uint, nk_rect) @nogc nothrow;
	void nk_popup_close(nk_context*) @nogc nothrow;
	void nk_popup_end(nk_context*) @nogc nothrow;
	void nk_popup_get_scroll(nk_context*, uint*, uint*) @nogc nothrow;
	void nk_popup_set_scroll(nk_context*, uint, uint) @nogc nothrow;
	int nk_combo(nk_context*, const(char)**, int, int, int, nk_vec2) @nogc nothrow;
	int nk_combo_separator(nk_context*, const(char)*, int, int, int, int, nk_vec2) @nogc nothrow;
	int nk_combo_string(nk_context*, const(char)*, int, int, int, nk_vec2) @nogc nothrow;
	int nk_combo_callback(nk_context*, void function(void*, int, const(char)**), void*, int, int, int, nk_vec2) @nogc nothrow;
	void nk_combobox(nk_context*, const(char)**, int, int*, int, nk_vec2) @nogc nothrow;
	void nk_combobox_string(nk_context*, const(char)*, int*, int, int, nk_vec2) @nogc nothrow;
	void nk_combobox_separator(nk_context*, const(char)*, int, int*, int, int, nk_vec2) @nogc nothrow;
	void nk_combobox_callback(nk_context*, void function(void*, int, const(char)**), void*, int*, int, int, nk_vec2) @nogc nothrow;
	bool nk_combo_begin_text(nk_context*, const(char)*, int, nk_vec2) @nogc nothrow;
	bool nk_combo_begin_label(nk_context*, const(char)*, nk_vec2) @nogc nothrow;
	bool nk_combo_begin_color(nk_context*, nk_color, nk_vec2) @nogc nothrow;
	bool nk_combo_begin_symbol(nk_context*, nk_symbol_type, nk_vec2) @nogc nothrow;
	bool nk_combo_begin_symbol_label(nk_context*, const(char)*, nk_symbol_type, nk_vec2) @nogc nothrow;
	bool nk_combo_begin_symbol_text(nk_context*, const(char)*, int, nk_symbol_type, nk_vec2) @nogc nothrow;
	bool nk_combo_begin_image(nk_context*, nk_image, nk_vec2) @nogc nothrow;
	bool nk_combo_begin_image_label(nk_context*, const(char)*, nk_image, nk_vec2) @nogc nothrow;
	bool nk_combo_begin_image_text(nk_context*, const(char)*, int, nk_image, nk_vec2) @nogc nothrow;
	bool nk_combo_item_label(nk_context*, const(char)*, uint) @nogc nothrow;
	bool nk_combo_item_text(nk_context*, const(char)*, int, uint) @nogc nothrow;
	bool nk_combo_item_image_label(nk_context*, nk_image, const(char)*, uint) @nogc nothrow;
	bool nk_combo_item_image_text(nk_context*, nk_image, const(char)*, int, uint) @nogc nothrow;
	bool nk_combo_item_symbol_label(nk_context*, nk_symbol_type, const(char)*, uint) @nogc nothrow;
	bool nk_combo_item_symbol_text(nk_context*, nk_symbol_type, const(char)*, int, uint) @nogc nothrow;
	void nk_combo_close(nk_context*) @nogc nothrow;
	void nk_combo_end(nk_context*) @nogc nothrow;
	bool nk_contextual_begin(nk_context*, uint, nk_vec2, nk_rect) @nogc nothrow;
	bool nk_contextual_item_text(nk_context*, const(char)*, int, uint) @nogc nothrow;
	bool nk_contextual_item_label(nk_context*, const(char)*, uint) @nogc nothrow;
	bool nk_contextual_item_image_label(nk_context*, nk_image, const(char)*, uint) @nogc nothrow;
	bool nk_contextual_item_image_text(nk_context*, nk_image, const(char)*, int, uint) @nogc nothrow;
	bool nk_contextual_item_symbol_label(nk_context*, nk_symbol_type, const(char)*, uint) @nogc nothrow;
	bool nk_contextual_item_symbol_text(nk_context*, nk_symbol_type, const(char)*, int, uint) @nogc nothrow;
	void nk_contextual_close(nk_context*) @nogc nothrow;
	void nk_contextual_end(nk_context*) @nogc nothrow;
	void nk_tooltip(nk_context*, const(char)*) @nogc nothrow;
	void nk_tooltipf(nk_context*, const(char)*, ...) @nogc nothrow;
	void nk_tooltipfv(nk_context*, const(char)*, char*) @nogc nothrow;
	bool nk_tooltip_begin(nk_context*, float) @nogc nothrow;
	void nk_tooltip_end(nk_context*) @nogc nothrow;
	void nk_menubar_begin(nk_context*) @nogc nothrow;
	void nk_menubar_end(nk_context*) @nogc nothrow;
	bool nk_menu_begin_text(nk_context*, const(char)*, int, uint, nk_vec2) @nogc nothrow;
	bool nk_menu_begin_label(nk_context*, const(char)*, uint, nk_vec2) @nogc nothrow;
	bool nk_menu_begin_image(nk_context*, const(char)*, nk_image, nk_vec2) @nogc nothrow;
	bool nk_menu_begin_image_text(nk_context*, const(char)*, int, uint, nk_image, nk_vec2) @nogc nothrow;
	bool nk_menu_begin_image_label(nk_context*, const(char)*, uint, nk_image, nk_vec2) @nogc nothrow;
	bool nk_menu_begin_symbol(nk_context*, const(char)*, nk_symbol_type, nk_vec2) @nogc nothrow;
	bool nk_menu_begin_symbol_text(nk_context*, const(char)*, int, uint, nk_symbol_type, nk_vec2) @nogc nothrow;
	bool nk_menu_begin_symbol_label(nk_context*, const(char)*, uint, nk_symbol_type, nk_vec2) @nogc nothrow;
	bool nk_menu_item_text(nk_context*, const(char)*, int, uint) @nogc nothrow;
	bool nk_menu_item_label(nk_context*, const(char)*, uint) @nogc nothrow;
	bool nk_menu_item_image_label(nk_context*, nk_image, const(char)*, uint) @nogc nothrow;
	bool nk_menu_item_image_text(nk_context*, nk_image, const(char)*, int, uint) @nogc nothrow;
	bool nk_menu_item_symbol_text(nk_context*, nk_symbol_type, const(char)*, int, uint) @nogc nothrow;
	bool nk_menu_item_symbol_label(nk_context*, nk_symbol_type, const(char)*, uint) @nogc nothrow;
	void nk_menu_close(nk_context*) @nogc nothrow;
	void nk_menu_end(nk_context*) @nogc nothrow;
	enum nk_style_colors
	{
		NK_COLOR_TEXT = 0,
		NK_COLOR_WINDOW = 1,
		NK_COLOR_HEADER = 2,
		NK_COLOR_BORDER = 3,
		NK_COLOR_BUTTON = 4,
		NK_COLOR_BUTTON_HOVER = 5,
		NK_COLOR_BUTTON_ACTIVE = 6,
		NK_COLOR_TOGGLE = 7,
		NK_COLOR_TOGGLE_HOVER = 8,
		NK_COLOR_TOGGLE_CURSOR = 9,
		NK_COLOR_SELECT = 10,
		NK_COLOR_SELECT_ACTIVE = 11,
		NK_COLOR_SLIDER = 12,
		NK_COLOR_SLIDER_CURSOR = 13,
		NK_COLOR_SLIDER_CURSOR_HOVER = 14,
		NK_COLOR_SLIDER_CURSOR_ACTIVE = 15,
		NK_COLOR_PROPERTY = 16,
		NK_COLOR_EDIT = 17,
		NK_COLOR_EDIT_CURSOR = 18,
		NK_COLOR_COMBO = 19,
		NK_COLOR_CHART = 20,
		NK_COLOR_CHART_COLOR = 21,
		NK_COLOR_CHART_COLOR_HIGHLIGHT = 22,
		NK_COLOR_SCROLLBAR = 23,
		NK_COLOR_SCROLLBAR_CURSOR = 24,
		NK_COLOR_SCROLLBAR_CURSOR_HOVER = 25,
		NK_COLOR_SCROLLBAR_CURSOR_ACTIVE = 26,
		NK_COLOR_TAB_HEADER = 27,
		NK_COLOR_COUNT = 28,
	}

	enum NK_COLOR_TEXT = nk_style_colors.NK_COLOR_TEXT;
	enum NK_COLOR_WINDOW = nk_style_colors.NK_COLOR_WINDOW;
	enum NK_COLOR_HEADER = nk_style_colors.NK_COLOR_HEADER;
	enum NK_COLOR_BORDER = nk_style_colors.NK_COLOR_BORDER;
	enum NK_COLOR_BUTTON = nk_style_colors.NK_COLOR_BUTTON;
	enum NK_COLOR_BUTTON_HOVER = nk_style_colors.NK_COLOR_BUTTON_HOVER;
	enum NK_COLOR_BUTTON_ACTIVE = nk_style_colors.NK_COLOR_BUTTON_ACTIVE;
	enum NK_COLOR_TOGGLE = nk_style_colors.NK_COLOR_TOGGLE;
	enum NK_COLOR_TOGGLE_HOVER = nk_style_colors.NK_COLOR_TOGGLE_HOVER;
	enum NK_COLOR_TOGGLE_CURSOR = nk_style_colors.NK_COLOR_TOGGLE_CURSOR;
	enum NK_COLOR_SELECT = nk_style_colors.NK_COLOR_SELECT;
	enum NK_COLOR_SELECT_ACTIVE = nk_style_colors.NK_COLOR_SELECT_ACTIVE;
	enum NK_COLOR_SLIDER = nk_style_colors.NK_COLOR_SLIDER;
	enum NK_COLOR_SLIDER_CURSOR = nk_style_colors.NK_COLOR_SLIDER_CURSOR;
	enum NK_COLOR_SLIDER_CURSOR_HOVER = nk_style_colors.NK_COLOR_SLIDER_CURSOR_HOVER;
	enum NK_COLOR_SLIDER_CURSOR_ACTIVE = nk_style_colors.NK_COLOR_SLIDER_CURSOR_ACTIVE;
	enum NK_COLOR_PROPERTY = nk_style_colors.NK_COLOR_PROPERTY;
	enum NK_COLOR_EDIT = nk_style_colors.NK_COLOR_EDIT;
	enum NK_COLOR_EDIT_CURSOR = nk_style_colors.NK_COLOR_EDIT_CURSOR;
	enum NK_COLOR_COMBO = nk_style_colors.NK_COLOR_COMBO;
	enum NK_COLOR_CHART = nk_style_colors.NK_COLOR_CHART;
	enum NK_COLOR_CHART_COLOR = nk_style_colors.NK_COLOR_CHART_COLOR;
	enum NK_COLOR_CHART_COLOR_HIGHLIGHT = nk_style_colors.NK_COLOR_CHART_COLOR_HIGHLIGHT;
	enum NK_COLOR_SCROLLBAR = nk_style_colors.NK_COLOR_SCROLLBAR;
	enum NK_COLOR_SCROLLBAR_CURSOR = nk_style_colors.NK_COLOR_SCROLLBAR_CURSOR;
	enum NK_COLOR_SCROLLBAR_CURSOR_HOVER = nk_style_colors.NK_COLOR_SCROLLBAR_CURSOR_HOVER;
	enum NK_COLOR_SCROLLBAR_CURSOR_ACTIVE = nk_style_colors.NK_COLOR_SCROLLBAR_CURSOR_ACTIVE;
	enum NK_COLOR_TAB_HEADER = nk_style_colors.NK_COLOR_TAB_HEADER;
	enum NK_COLOR_COUNT = nk_style_colors.NK_COLOR_COUNT;
	enum nk_style_cursor
	{
		NK_CURSOR_ARROW = 0,
		NK_CURSOR_TEXT = 1,
		NK_CURSOR_MOVE = 2,
		NK_CURSOR_RESIZE_VERTICAL = 3,
		NK_CURSOR_RESIZE_HORIZONTAL = 4,
		NK_CURSOR_RESIZE_TOP_LEFT_DOWN_RIGHT = 5,
		NK_CURSOR_RESIZE_TOP_RIGHT_DOWN_LEFT = 6,
		NK_CURSOR_COUNT = 7,
	}

	enum NK_CURSOR_ARROW = nk_style_cursor.NK_CURSOR_ARROW;
	enum NK_CURSOR_TEXT = nk_style_cursor.NK_CURSOR_TEXT;
	enum NK_CURSOR_MOVE = nk_style_cursor.NK_CURSOR_MOVE;
	enum NK_CURSOR_RESIZE_VERTICAL = nk_style_cursor.NK_CURSOR_RESIZE_VERTICAL;
	enum NK_CURSOR_RESIZE_HORIZONTAL = nk_style_cursor.NK_CURSOR_RESIZE_HORIZONTAL;
	enum NK_CURSOR_RESIZE_TOP_LEFT_DOWN_RIGHT = nk_style_cursor.NK_CURSOR_RESIZE_TOP_LEFT_DOWN_RIGHT;
	enum NK_CURSOR_RESIZE_TOP_RIGHT_DOWN_LEFT = nk_style_cursor.NK_CURSOR_RESIZE_TOP_RIGHT_DOWN_LEFT;
	enum NK_CURSOR_COUNT = nk_style_cursor.NK_CURSOR_COUNT;
	void nk_style_default(nk_context*) @nogc nothrow;
	void nk_style_from_table(nk_context*, const(nk_color)*) @nogc nothrow;
	void nk_style_load_cursor(nk_context*, nk_style_cursor, const(nk_cursor)*) @nogc nothrow;
	void nk_style_load_all_cursors(nk_context*, nk_cursor*) @nogc nothrow;
	const(char)* nk_style_get_color_by_name(nk_style_colors) @nogc nothrow;
	void nk_style_set_font(nk_context*, const(nk_user_font)*) @nogc nothrow;
	bool nk_style_set_cursor(nk_context*, nk_style_cursor) @nogc nothrow;
	void nk_style_show_cursor(nk_context*) @nogc nothrow;
	void nk_style_hide_cursor(nk_context*) @nogc nothrow;
	bool nk_style_push_font(nk_context*, const(nk_user_font)*) @nogc nothrow;
	bool nk_style_push_float(nk_context*, float*, float) @nogc nothrow;
	bool nk_style_push_vec2(nk_context*, nk_vec2*, nk_vec2) @nogc nothrow;
	bool nk_style_push_style_item(nk_context*, nk_style_item*, nk_style_item) @nogc nothrow;
	bool nk_style_push_flags(nk_context*, uint*, uint) @nogc nothrow;
	bool nk_style_push_color(nk_context*, nk_color*, nk_color) @nogc nothrow;
	bool nk_style_pop_font(nk_context*) @nogc nothrow;
	bool nk_style_pop_float(nk_context*) @nogc nothrow;
	bool nk_style_pop_vec2(nk_context*) @nogc nothrow;
	bool nk_style_pop_style_item(nk_context*) @nogc nothrow;
	bool nk_style_pop_flags(nk_context*) @nogc nothrow;
	bool nk_style_pop_color(nk_context*) @nogc nothrow;
	nk_color nk_rgb(int, int, int) @nogc nothrow;
	nk_color nk_rgb_iv(const(int)*) @nogc nothrow;
	nk_color nk_rgb_bv(const(ubyte)*) @nogc nothrow;
	nk_color nk_rgb_f(float, float, float) @nogc nothrow;
	nk_color nk_rgb_fv(const(float)*) @nogc nothrow;
	nk_color nk_rgb_cf(nk_colorf) @nogc nothrow;
	nk_color nk_rgb_hex(const(char)*) @nogc nothrow;
	nk_color nk_rgba(int, int, int, int) @nogc nothrow;
	nk_color nk_rgba_u32(uint) @nogc nothrow;
	nk_color nk_rgba_iv(const(int)*) @nogc nothrow;
	nk_color nk_rgba_bv(const(ubyte)*) @nogc nothrow;
	nk_color nk_rgba_f(float, float, float, float) @nogc nothrow;
	nk_color nk_rgba_fv(const(float)*) @nogc nothrow;
	nk_color nk_rgba_cf(nk_colorf) @nogc nothrow;
	nk_color nk_rgba_hex(const(char)*) @nogc nothrow;
	nk_colorf nk_hsva_colorf(float, float, float, float) @nogc nothrow;
	nk_colorf nk_hsva_colorfv(float*) @nogc nothrow;
	void nk_colorf_hsva_f(float*, float*, float*, float*, nk_colorf) @nogc nothrow;
	void nk_colorf_hsva_fv(float*, nk_colorf) @nogc nothrow;
	nk_color nk_hsv(int, int, int) @nogc nothrow;
	nk_color nk_hsv_iv(const(int)*) @nogc nothrow;
	nk_color nk_hsv_bv(const(ubyte)*) @nogc nothrow;
	nk_color nk_hsv_f(float, float, float) @nogc nothrow;
	nk_color nk_hsv_fv(const(float)*) @nogc nothrow;
	nk_color nk_hsva(int, int, int, int) @nogc nothrow;
	nk_color nk_hsva_iv(const(int)*) @nogc nothrow;
	nk_color nk_hsva_bv(const(ubyte)*) @nogc nothrow;
	nk_color nk_hsva_f(float, float, float, float) @nogc nothrow;
	nk_color nk_hsva_fv(const(float)*) @nogc nothrow;
	void nk_color_f(float*, float*, float*, float*, nk_color) @nogc nothrow;
	void nk_color_fv(float*, nk_color) @nogc nothrow;
	nk_colorf nk_color_cf(nk_color) @nogc nothrow;
	void nk_color_d(double*, double*, double*, double*, nk_color) @nogc nothrow;
	void nk_color_dv(double*, nk_color) @nogc nothrow;
	uint nk_color_u32(nk_color) @nogc nothrow;
	void nk_color_hex_rgba(char*, nk_color) @nogc nothrow;
	void nk_color_hex_rgb(char*, nk_color) @nogc nothrow;
	void nk_color_hsv_i(int*, int*, int*, nk_color) @nogc nothrow;
	void nk_color_hsv_b(ubyte*, ubyte*, ubyte*, nk_color) @nogc nothrow;
	void nk_color_hsv_iv(int*, nk_color) @nogc nothrow;
	void nk_color_hsv_bv(ubyte*, nk_color) @nogc nothrow;
	void nk_color_hsv_f(float*, float*, float*, nk_color) @nogc nothrow;
	void nk_color_hsv_fv(float*, nk_color) @nogc nothrow;
	void nk_color_hsva_i(int*, int*, int*, int*, nk_color) @nogc nothrow;
	void nk_color_hsva_b(ubyte*, ubyte*, ubyte*, ubyte*, nk_color) @nogc nothrow;
	void nk_color_hsva_iv(int*, nk_color) @nogc nothrow;
	void nk_color_hsva_bv(ubyte*, nk_color) @nogc nothrow;
	void nk_color_hsva_f(float*, float*, float*, float*, nk_color) @nogc nothrow;
	void nk_color_hsva_fv(float*, nk_color) @nogc nothrow;
	nk_handle nk_handle_ptr(void*) @nogc nothrow;
	nk_handle nk_handle_id(int) @nogc nothrow;
	nk_image nk_image_handle(nk_handle) @nogc nothrow;
	nk_image nk_image_ptr(void*) @nogc nothrow;
	nk_image nk_image_id(int) @nogc nothrow;
	bool nk_image_is_subimage(const(nk_image)*) @nogc nothrow;
	nk_image nk_subimage_ptr(void*, ushort, ushort, nk_rect) @nogc nothrow;
	nk_image nk_subimage_id(int, ushort, ushort, nk_rect) @nogc nothrow;
	nk_image nk_subimage_handle(nk_handle, ushort, ushort, nk_rect) @nogc nothrow;
	nk_nine_slice nk_nine_slice_handle(nk_handle, ushort, ushort, ushort, ushort) @nogc nothrow;
	nk_nine_slice nk_nine_slice_ptr(void*, ushort, ushort, ushort, ushort) @nogc nothrow;
	nk_nine_slice nk_nine_slice_id(int, ushort, ushort, ushort, ushort) @nogc nothrow;
	int nk_nine_slice_is_sub9slice(const(nk_nine_slice)*) @nogc nothrow;
	nk_nine_slice nk_sub9slice_ptr(void*, ushort, ushort, nk_rect, ushort, ushort, ushort, ushort) @nogc nothrow;
	nk_nine_slice nk_sub9slice_id(int, ushort, ushort, nk_rect, ushort, ushort, ushort, ushort) @nogc nothrow;
	nk_nine_slice nk_sub9slice_handle(nk_handle, ushort, ushort, nk_rect, ushort, ushort, ushort, ushort) @nogc nothrow;
	uint nk_murmur_hash(const(void)*, int, uint) @nogc nothrow;
	void nk_triangle_from_direction(nk_vec2*, nk_rect, float, float, nk_heading) @nogc nothrow;
	pragma(mangle, "nk_vec2") nk_vec2 nk_vec2_(float, float) @nogc nothrow;
	pragma(mangle, "nk_vec2i") nk_vec2 nk_vec2i_(int, int) @nogc nothrow;
	nk_vec2 nk_vec2v(const(float)*) @nogc nothrow;
	nk_vec2 nk_vec2iv(const(int)*) @nogc nothrow;
	nk_rect nk_get_null_rect() @nogc nothrow;
	pragma(mangle, "nk_rect") nk_rect nk_rect_(float, float, float, float) @nogc nothrow;
	pragma(mangle, "nk_recti") nk_rect nk_recti_(int, int, int, int) @nogc nothrow;
	nk_rect nk_recta(nk_vec2, nk_vec2) @nogc nothrow;
	nk_rect nk_rectv(const(float)*) @nogc nothrow;
	nk_rect nk_rectiv(const(int)*) @nogc nothrow;
	nk_vec2 nk_rect_pos(nk_rect) @nogc nothrow;
	nk_vec2 nk_rect_size(nk_rect) @nogc nothrow;
	int nk_strlen(const(char)*) @nogc nothrow;
	int nk_stricmp(const(char)*, const(char)*) @nogc nothrow;
	int nk_stricmpn(const(char)*, const(char)*, int) @nogc nothrow;
	int nk_strtoi(const(char)*, const(char)**) @nogc nothrow;
	float nk_strtof(const(char)*, const(char)**) @nogc nothrow;
	struct nk_clipboard
	{
		nk_handle userdata;
		void function(nk_handle, nk_text_edit*) paste;
		void function(nk_handle, const(char)*, int) copy;
	}

	double nk_strtod(const(char)*, const(char)**) @nogc nothrow;
	int nk_strfilter(const(char)*, const(char)*) @nogc nothrow;
	int nk_strmatch_fuzzy_string(const(char)*, const(char)*, int*) @nogc nothrow;
	int nk_strmatch_fuzzy_text(const(char)*, int, const(char)*, int*) @nogc nothrow;
	int nk_utf_decode(const(char)*, uint*, int) @nogc nothrow;
	int nk_utf_encode(uint, char*, int) @nogc nothrow;
	int nk_utf_len(const(char)*, int) @nogc nothrow;
	const(char)* nk_utf_at(const(char)*, int, int, uint*, int*) @nogc nothrow;
	struct nk_user_font_glyph
	{
		nk_vec2[2] uv;
		nk_vec2 offset;
		float width;
		float height;
		float xadvance;
	}

	alias nk_text_width_f = float function(nk_handle, float, const(char)*, int);
	alias nk_query_font_glyph_f = void function(nk_handle, float, nk_user_font_glyph*, uint, uint);
	enum nk_font_coord_type
	{
		NK_COORD_UV = 0,
		NK_COORD_PIXEL = 1,
	}

	enum NK_COORD_UV = nk_font_coord_type.NK_COORD_UV;
	enum NK_COORD_PIXEL = nk_font_coord_type.NK_COORD_PIXEL;
	struct nk_font
	{
		nk_font* next;
		nk_user_font handle;
		nk_baked_font info;
		float scale;
		nk_font_glyph* glyphs;
		const(nk_font_glyph)* fallback;
		uint fallback_codepoint;
		nk_handle texture;
		nk_font_config* config;
	}

	struct nk_baked_font
	{
		float height;
		float ascent;
		float descent;
		uint glyph_offset;
		uint glyph_count;
		const(uint)* ranges;
	}

	struct nk_font_config
	{
		nk_font_config* next;
		void* ttf_blob;
		size_t ttf_size;
		ubyte ttf_data_owned_by_atlas;
		ubyte merge_mode;
		ubyte pixel_snap;
		ubyte oversample_v;
		ubyte oversample_h;
		ubyte[3] padding;
		float size;
		nk_font_coord_type coord_type;
		nk_vec2 spacing;
		const(uint)* range;
		nk_baked_font* font;
		uint fallback_glyph;
		nk_font_config* n;
		nk_font_config* p;
	}

	struct nk_font_glyph
	{
		uint codepoint;
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

	enum nk_font_atlas_format
	{
		NK_FONT_ATLAS_ALPHA8 = 0,
		NK_FONT_ATLAS_RGBA32 = 1,
	}

	enum NK_FONT_ATLAS_ALPHA8 = nk_font_atlas_format.NK_FONT_ATLAS_ALPHA8;
	enum NK_FONT_ATLAS_RGBA32 = nk_font_atlas_format.NK_FONT_ATLAS_RGBA32;
	struct nk_font_atlas
	{
		void* pixel;
		int tex_width;
		int tex_height;
		nk_allocator permanent;
		nk_allocator temporary;
		nk_recti custom;
		nk_cursor[7] cursors;
		int glyph_count;
		nk_font_glyph* glyphs;
		nk_font* default_font;
		nk_font* fonts;
		nk_font_config* config;
		int font_num;
	}

	const(uint)* nk_font_default_glyph_ranges() @nogc nothrow;
	const(uint)* nk_font_chinese_glyph_ranges() @nogc nothrow;
	const(uint)* nk_font_cyrillic_glyph_ranges() @nogc nothrow;
	const(uint)* nk_font_korean_glyph_ranges() @nogc nothrow;
	void nk_font_atlas_init_default(nk_font_atlas*) @nogc nothrow;
	void nk_font_atlas_init(nk_font_atlas*, nk_allocator*) @nogc nothrow;
	void nk_font_atlas_init_custom(nk_font_atlas*, nk_allocator*, nk_allocator*) @nogc nothrow;
	void nk_font_atlas_begin(nk_font_atlas*) @nogc nothrow;
	pragma(mangle, "nk_font_config") nk_font_config nk_font_config_(float) @nogc nothrow;
	nk_font* nk_font_atlas_add(nk_font_atlas*, const(nk_font_config)*) @nogc nothrow;
	nk_font* nk_font_atlas_add_from_memory(nk_font_atlas*, void*, size_t, float, const(nk_font_config)*) @nogc nothrow;
	nk_font* nk_font_atlas_add_compressed(nk_font_atlas*, void*, size_t, float, const(nk_font_config)*) @nogc nothrow;
	nk_font* nk_font_atlas_add_compressed_base85(nk_font_atlas*, const(char)*, float, const(nk_font_config)*) @nogc nothrow;
	const(void)* nk_font_atlas_bake(nk_font_atlas*, int*, int*, nk_font_atlas_format) @nogc nothrow;
	void nk_font_atlas_end(nk_font_atlas*, nk_handle, nk_draw_null_texture*) @nogc nothrow;
	const(nk_font_glyph)* nk_font_find_glyph(nk_font*, uint) @nogc nothrow;
	void nk_font_atlas_cleanup(nk_font_atlas*) @nogc nothrow;
	void nk_font_atlas_clear(nk_font_atlas*) @nogc nothrow;
	struct nk_memory_status
	{
		void* memory;
		uint type;
		size_t size;
		size_t allocated;
		size_t needed;
		size_t calls;
	}

	enum nk_allocation_type
	{
		NK_BUFFER_FIXED = 0,
		NK_BUFFER_DYNAMIC = 1,
	}

	enum NK_BUFFER_FIXED = nk_allocation_type.NK_BUFFER_FIXED;
	enum NK_BUFFER_DYNAMIC = nk_allocation_type.NK_BUFFER_DYNAMIC;
	enum nk_buffer_allocation_type
	{
		NK_BUFFER_FRONT = 0,
		NK_BUFFER_BACK = 1,
		NK_BUFFER_MAX = 2,
	}

	enum NK_BUFFER_FRONT = nk_buffer_allocation_type.NK_BUFFER_FRONT;
	enum NK_BUFFER_BACK = nk_buffer_allocation_type.NK_BUFFER_BACK;
	enum NK_BUFFER_MAX = nk_buffer_allocation_type.NK_BUFFER_MAX;
	struct nk_buffer_marker
	{
		bool active;
		size_t offset;
	}

	struct nk_memory
	{
		void* ptr;
		size_t size;
	}

	void nk_buffer_init_default(nk_buffer*) @nogc nothrow;
	void nk_buffer_init(nk_buffer*, const(nk_allocator)*, size_t) @nogc nothrow;
	void nk_buffer_init_fixed(nk_buffer*, void*, size_t) @nogc nothrow;
	void nk_buffer_info(nk_memory_status*, nk_buffer*) @nogc nothrow;
	void nk_buffer_push(nk_buffer*, nk_buffer_allocation_type, const(void)*, size_t, size_t) @nogc nothrow;
	void nk_buffer_mark(nk_buffer*, nk_buffer_allocation_type) @nogc nothrow;
	void nk_buffer_reset(nk_buffer*, nk_buffer_allocation_type) @nogc nothrow;
	void nk_buffer_clear(nk_buffer*) @nogc nothrow;
	void nk_buffer_free(nk_buffer*) @nogc nothrow;
	void* nk_buffer_memory(nk_buffer*) @nogc nothrow;
	const(void)* nk_buffer_memory_const(const(nk_buffer)*) @nogc nothrow;
	size_t nk_buffer_total(nk_buffer*) @nogc nothrow;
	struct nk_str
	{
		nk_buffer buffer;
		int len;
	}

	void nk_str_init_default(nk_str*) @nogc nothrow;
	void nk_str_init(nk_str*, const(nk_allocator)*, size_t) @nogc nothrow;
	void nk_str_init_fixed(nk_str*, void*, size_t) @nogc nothrow;
	void nk_str_clear(nk_str*) @nogc nothrow;
	void nk_str_free(nk_str*) @nogc nothrow;
	int nk_str_append_text_char(nk_str*, const(char)*, int) @nogc nothrow;
	int nk_str_append_str_char(nk_str*, const(char)*) @nogc nothrow;
	int nk_str_append_text_utf8(nk_str*, const(char)*, int) @nogc nothrow;
	int nk_str_append_str_utf8(nk_str*, const(char)*) @nogc nothrow;
	int nk_str_append_text_runes(nk_str*, const(uint)*, int) @nogc nothrow;
	int nk_str_append_str_runes(nk_str*, const(uint)*) @nogc nothrow;
	int nk_str_insert_at_char(nk_str*, int, const(char)*, int) @nogc nothrow;
	int nk_str_insert_at_rune(nk_str*, int, const(char)*, int) @nogc nothrow;
	int nk_str_insert_text_char(nk_str*, int, const(char)*, int) @nogc nothrow;
	int nk_str_insert_str_char(nk_str*, int, const(char)*) @nogc nothrow;
	int nk_str_insert_text_utf8(nk_str*, int, const(char)*, int) @nogc nothrow;
	int nk_str_insert_str_utf8(nk_str*, int, const(char)*) @nogc nothrow;
	int nk_str_insert_text_runes(nk_str*, int, const(uint)*, int) @nogc nothrow;
	int nk_str_insert_str_runes(nk_str*, int, const(uint)*) @nogc nothrow;
	void nk_str_remove_chars(nk_str*, int) @nogc nothrow;
	void nk_str_remove_runes(nk_str*, int) @nogc nothrow;
	void nk_str_delete_chars(nk_str*, int, int) @nogc nothrow;
	void nk_str_delete_runes(nk_str*, int, int) @nogc nothrow;
	char* nk_str_at_char(nk_str*, int) @nogc nothrow;
	char* nk_str_at_rune(nk_str*, int, uint*, int*) @nogc nothrow;
	uint nk_str_rune_at(const(nk_str)*, int) @nogc nothrow;
	const(char)* nk_str_at_char_const(const(nk_str)*, int) @nogc nothrow;
	const(char)* nk_str_at_const(const(nk_str)*, int, uint*, int*) @nogc nothrow;
	char* nk_str_get(nk_str*) @nogc nothrow;
	const(char)* nk_str_get_const(const(nk_str)*) @nogc nothrow;
	int nk_str_len(nk_str*) @nogc nothrow;
	int nk_str_len_char(nk_str*) @nogc nothrow;
}
