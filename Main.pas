unit Main;

{$mode objfpc}{$H+,M+,R-,I+,Q-,SMARTLINK+,INLINE+}

interface

uses

  {ZLib,}
  Graphics, Classes, SysUtils, Forms, ComCtrls, GraphType, LResources, Dialogs, FileUtil,
  Math, Menus, StdCtrls, ExtCtrls, Buttons, Controls, Spin, ExtDlgs, ComboEx, MMSystem,
  {$ifdef Windows}
  Windows, WinInet, ImgList,
  {$endif}
  {$ifdef Linux}
  Linux,Unix,
  {$endif}
  IniFiles, Types, TypInfo, Mouse,
  {Own Units}
  Fast_AnimK, Fast_Primitives, Scene_Tree, Performance_Time, OpenGLContext,
  lclvlc, GL, GLU, Game;

const

  NAV_SEL_COL_0=$009DD7E6;
  NAV_SEL_COL_1=$00C8CFA9;

  {Resources Paths}
  SELECTION_TOOLS_MARKER           ='Pics\Selection_Tools\Selection_Tools_Marker.png';
  DEFAULT_CURSOR_ICON              ='Pics\Cursors\Cursor_0.png';
  DEFAULT_TILE_MAP_ICON            ='Pics\Map_Editor\Default_Tile_Map_Icon.png';
  DEFAULT_TILE_MAP_SPRITE_ICON     ='Pics\Map_Editor\Default_Tile_Map_Sprite_Icon0.png';
  DEFAULT_ACTOR_ICON               ='Pics\Actors\Default_Actor_Icon.png';
  TIMELINE_BUTTON_ICON_PREFIX      ='Pics\TimeLine\Timeline_Button_Icon_';
  TEXT_BUTTON_ICON                 ='Pics\Paint_Tools_Icons_List\Text.png';
  BRUSH_BUTTON_ICON                ='Pics\Paint_Tools_Icons_List\Brush.png';
  SPRAY_BUTTON_ICON                ='Pics\Paint_Tools_Icons_List\Spray.png';
  SPLINE_BUTTON_ICON               ='Pics\Paint_Tools_Icons_List\Spline.png';
  SELECT_POINTS_BUTTON_ICON        ='Pics\Paint_Tools_Icons_List\Select_Points.png';
  SELECT_TEXTURE_REGION_BUTTON_ICON='Pics\Paint_Tools_Icons_List\Select_Texture_Region.png';
  REGULAR_GRID_BUTTON_ICON         ='Pics\Paint_Tools_Icons_List\Grid.png';
  SNAP_GRID_BUTTON_ICON            ='Pics\Paint_Tools_Icons_List\Snap_Grid.png';
  BRUSH_CURSOR_ICON                ='Pics\Cursors\Cursor_3.png';
  WORLD_AXIS_ICON                  ='Pics\World_Axis\World_Axis.png';

(***************************** Miscellaneous Types ****************************)
type

  TEventGroupEnum    =set of byte;
  PEventGroupEnum    =^TEventGroupEnum;

  {Background Post-Processing}
  TBackgroundStyle   =(bsGrayscale,bsBlur,bsBoth,bsNone);
  PBackgroundStyle   =^TBackgroundStyle;

  {Selection Mode}
  TSelectionMode     =(smCircle,smBrush,smRectangle,smRegion,smSelectAll);
  PSelectionMode     =^TSelectionMode;

  {Points}
  TPtsKind           =(pkAll,pkObj,pkSelected);
  {pkAll      - all points of spline;
   pkObj      - points of single spline object;
   pkSelected - selected points of all splines;}
  PPtsKind           =^TPtsKind;

  {Pivot}
  TPivotMode         =(pmPivotMove,pmPivotScale,pmPivotRotate);
  PPivotMode         =^TPivotMode;

  PControl           =^TControl;

  TSavedUpPts        =class;
  TSurf              =class;
  TSurfInst          =class;
  TTex               =class;
  TRGrid             =class;
  TSGrid             =class;
  TCurve             =class;
  TUV                =class;
  TISGraph           =class;
  TSelPts            =class;
  TPivot             =class;
  TCircSel           =class;
  TBrushSel          =class;
  TRectSel           =class;
  TTlMap             =class;

  {TF_MainForm--------}
  TF_MainForm        =class(TForm) {$region -fold}
    BB_Bottom_Splitter_To_Left                       : TBitBtn;
    BB_Copy_UV                                       : TBitBtn;
    BB_Delete_All                                    : TBitBtn;
    BB_Add_Sprite                                    : TBitBtn;
    BB_Spline_Templates_Left                         : TBitBtn;
    BB_Spline_Templates_Right                        : TBitBtn;
    BB_Load_Bitmap                                   : TBitBtn;
    BB_Delete_Selected                               : TBitBtn;
    BB_Load_Frame                                    : TBitBtn;
    BB_Reset_Angle                                   : TBitBtn;
    BB_Move_To_and_Merge                             : TBitBtn;
    BB_Apply_Bitmap_To_Spline                        : TBitBtn;
    BB_Generate                                      : TBitBtn;
    BB_Reset_Size                                    : TBitBtn;
    BB_Reset_Position                                : TBitBtn;
    BB_Save_UV                                       : TBitBtn;
    BB_Reset_UV                                      : TBitBtn;
    BB_Use_Magic                                     : TBitBtn;
    BB_Triangulate                                   : TBitBtn;
    BB_Mirror_V                                      : TBitBtn;
    BB_Merge_UV                                      : TBitBtn;
    BB_Paste_UV                                      : TBitBtn;
    BB_Mirror_U                                      : TBitBtn;
    BB_Set_Value_U                                   : TBitBtn;
    BB_Reset_Value_A                                 : TBitBtn;
    BB_Reset_Value_U                                 : TBitBtn;
    BB_Set_Value_V                                   : TBitBtn;
    BB_Reset_Value_V                                 : TBitBtn;
    BB_Set_Value_H                                   : TBitBtn;
    BB_Reset_Value_H                                 : TBitBtn;
    BB_Set_Value_W                                   : TBitBtn;
    BB_Reset_Value_W                                 : TBitBtn;
    BB_Set_Value_A                                   : TBitBtn;
    BB_Maximize_UV                                   : TBitBtn;
    BB_Untriangulate                                 : TBitBtn;
    BB_Bottom_Splitter_To_Right                      : TBitBtn;
    BB_Add_Tilemap                                   : TBitBtn;
    Button1                                          : TButton;
    CB_Brush_Mode1                                   : TComboBox;
    CB_Brush_Mode2                                   : TComboBox;
    CB_Cycloid_Direction_Y                           : TComboBox;
    CB_Physics_Deletion                              : TCheckBox;
    CB_Select_Points_Background_Style                : TComboBox;
    CB_Select_Points_Show_Bounds                     : TCheckBox;
    CB_Select_Points_Show_Selected_Edges             : TCheckBox;
    CB_Select_Points_Line_Style                      : TComboBox;
    CB_Select_Points_Clip_Style                      : TComboBox;
    CB_Select_Points_Only_Visible                    : TCheckBox;
    CB_Select_Points_Selection_Mode                  : TComboBox;
    CB_Splines_Deletion                              : TCheckBox;
    CB_Spline_Edges_Anti_Aliasing                    : TCheckBox;
    CB_Spline_Edges_LOD                              : TCheckBox;
    CB_Dynamics_Style                                : TComboBox;
    CB_Dynamics_Collider                             : TCheckBox;
    CB_Spline_Lazy_Repaint                           : TCheckBox;
    CB_Epicycloid_Hypocycloid                        : TCheckBox;
    CB_Spline_Byte_Mode                              : TCheckBox;
    CB_Spline_Hidden_Line_Elimination                : TCheckBox;
    CB_Spline_Edges_Style                            : TComboBox;
    CB_Spline_Edges_Shape                            : TComboBox;
    CB_Spline_Grid_Clipping                          : TCheckBox;
    CB_Spline_On_Out_Of_Window                       : TCheckBox;
    CB_Spline_On_Scale_Down                          : TCheckBox;
    CB_Spline_Points_Style                           : TComboBox;
    CB_Spline_Points_Shape                           : TComboBox;
    CB_Spline_Edges_Show_Bounds                      : TCheckBox;
    CB_Spline_Points_Show_Bounds                     : TCheckBox;
    CB_Cycloid_Direction_X                           : TComboBox;
    CB_Actors_Deletion                               : TCheckBox;
    CB_Tilemaps_Deletion                             : TCheckBox;
    CB_Groups_Deletion                               : TCheckBox;
    CB_Spline_Connect_Ends                           : TCheckBox;
    CB_Proportional                                  : TCheckBox;
    CB_Spline_Mode                                   : TComboBox;
    CB_Spline_Type                                   : TComboBox;
    CB_Particles_Deletion                            : TCheckBox;
    FontDialog1                                      : TFontDialog;
    FP_UV_Operations                                 : TFlowPanel;
    FP_Image_List                                    : TFlowPanel;
    FSE_Brush_Fall_Off1                              : TFloatSpinEdit;
    FSE_Brush_Fall_Off2                              : TFloatSpinEdit;
    FSE_Rose_Petals_Count                            : TFloatSpinEdit;
    FSE_Spline_Simplification_Angle                  : TFloatSpinEdit;
    FSE_Cycloid_Curvature                            : TFloatSpinEdit;
    IL_Default_Tile_Map_Icon                         : TImageList;
    IL_Scene_Tree_Image_List                         : TImageList;
    IL_Pivot_Bmp                                     : TImageList;
    IL_Butons_Icons                                  : TImageList;
    IL_Buttons_Background                            : TImageList;
    IL_Cursors_Icons                                 : TImageList;
    IL_Select_Points                                 : TImageList;
    IL_Spline_Templates                              : TImageList;
    IL_Arrow_Up_Down                                 : TImageList;
    IL_Drawing_Buttons                               : TImageList;
    Image20                                          : TImage;
    Image21                                          : TImage;
    Image22                                          : TImage;
    Image23                                          : TImage;
    Image6                                           : TImage;
    Image7                                           : TImage;
    IL_World_Axis                                    : TImageList;
    IL_AnimK                                         : TImageList;
    IL_Default_Mask_Template_Sprite_Icon             : TImageList;
    Image8                                           : TImage;
    Image9                                           : TImage;
    I_Frame_List                                     : TImage;
    Image18                                          : TImage;
    Image19                                          : TImage;
    Image4                                           : TImage;
    Image5                                           : TImage;
    IL_Add_Actor_Default_Icon                        : TImageList;
    I_Add_Mask_Template_List                         : TImage;
    I_Add_Sprite_List                                : TImage;
    I_Visibility_Panel                               : TImage;
    Label1                                           : TLabel;
    LCLVLCPlayer_Intro                               : TLCLVLCPlayer;
    L_Cycloid_Direction_Y                            : TLabel;
    L_Cycloid_Loops_Count                            : TLabel;
    L_Cycloid_Points_Count                           : TLabel;
    L_Cycloid_Radius                                 : TLabel;
    L_Cycloid_Curvature                              : TLabel;
    L_Rose_Angle                                     : TLabel;
    L_Rose_Petals_Count                              : TLabel;
    L_Rose_Points_Count                              : TLabel;
    L_Rose_Radius                                    : TLabel;
    L_Rose_Rotation                                  : TLabel;
    L_Save_Load                                      : TLabel;
    L_Exec_Time_Info                                 : TLabel;
    L_Speed                                          : TLabel;
    L_Brush_Fall_Off1                                : TLabel;
    L_Brush_Fall_Off2                                : TLabel;
    L_Brush_Hardness1                                : TLabel;
    L_Brush_Hardness2                                : TLabel;
    L_Brush_Mode1                                    : TLabel;
    L_Brush_Mode2                                    : TLabel;
    L_Brush_Size1                                    : TLabel;
    L_Brush_Size2                                    : TLabel;
    L_Count_X                                        : TLabel;
    L_Count_Y                                        : TLabel;
    L_Epicycloid_Rotation                            : TLabel;
    L_Epicycloid_Angle                               : TLabel;
    L_Dynamics                                       : TLabel;
    L_Dynamics_Style                                 : TLabel;
    L_RGrid_Color                                    : TLabel;
    L_Spline_Free_Memory                             : TLabel;
    L_Spline_Edges_Dash_Length                       : TLabel;
    L_Spline_Edges_Points_Radius                     : TLabel;
    L_Spline_Spray_Radius                            : TLabel;
    L_Spline_Remove_Brunching                        : TLabel;
    L_Spline_Optimization                            : TLabel;
    L_Spline_Drawing                                 : TLabel;
    L_Epicycloid_Points_Count                        : TLabel;
    L_Epicycloid_Petals_Count                        : TLabel;
    L_Epicycloid_Radius                              : TLabel;
    L_Spline_Freehand_Settings                       : TLabel;
    L_Object_Properties_Parallax_Shift               : TLabel;
    L_Spline_Templates_Name                          : TLabel;
    L_Spline_Points_Shape                            : TLabel;
    L_Spline_Edges_Shape                             : TLabel;
    L_Spline_Points_Rectangle_Inner_Rectangle        : TLabel;
    L_Spline_Edges_Settings                          : TLabel;
    L_Cycloid_Direction_X                            : TLabel;
    L_Object_Properties                              : TLabel;
    L_Spline_Points_Rectangle_Thikness_Left          : TLabel;
    L_Spline_Points_Count                            : TLabel;
    L_Spline_Points_Rectangle_Thikness_Top           : TLabel;
    L_Spline_Points_Rectangle_Thikness_Right         : TLabel;
    L_Spline_Points_Rectangle_Thikness_Bottom        : TLabel;
    L_Spline_Points_Rectangle_Inner_Rectangle_Height : TLabel;
    L_Spline_Edges                                   : TLabel;
    L_Spline_Points                                  : TLabel;
    L_Spline_Edges_Style                             : TLabel;
    L_Spline_Points_Style                            : TLabel;
    L_Spline_Edges_Width                             : TLabel;
    L_Spline_Points_Rectangle_Thickness              : TLabel;
    L_Spline_Edges_Color                             : TLabel;
    L_Spline_Points_Color                            : TLabel;
    L_Spline_Points_Rectangle_Inner_Rectangle_Width  : TLabel;
    L_Spline_Simplification_Angle                    : TLabel;
    L_Spline_Type                                    : TLabel;
    L_Inner_Subgraph_Color                           : TLabel;
    L_Selected_Points_Color                          : TLabel;
    L_Selective_Deletion                             : TLabel;
    L_Bitmap_Width                                   : TLabel;
    L_Bitmap_Height                                  : TLabel;
    L_Select_Points_Background_Style                 : TLabel;
    L_Select_Points_Relative_Bucket_Size             : TLabel;
    L_Select_Points_Bucket_Size_Value                : TLabel;
    L_Select_Points_Line_Style                       : TLabel;
    L_Outer_Subgraph_Color                           : TLabel;
    L_Select_Points_Clip_Style                       : TLabel;
    L_Spline_Points_Freq                             : TLabel;
    L_Select_Points_Selection_Mode                   : TLabel;
    L_Object_Info                                    : TLabel;
    L_Spline_Mode                                    : TLabel;
    L_Tag_Properties                                 : TLabel;
    Memo1                                            : TMemo;
    MI_Button_Style_3                                : TMenuItem;
    MI_Align_Image_On_Inner_Window_Resize            : TMenuItem;
    MenuItem5                                        : TMenuItem;
    MI_Button_Styles                                 : TMenuItem;
    MenuItem9                                        : TMenuItem;
    MI_Button_Style_2                                : TMenuItem;
    MenuItem7                                        : TMenuItem;
    MI_Button_Style_1                                : TMenuItem;
    MI_Full_Screen                                   : TMenuItem;
    MI_Trancparency                                  : TMenuItem;
    MI_Antialiasing                                  : TMenuItem;
    MI_Object_Info                                   : TMenuItem;
    MenuItem1                                        : TMenuItem;
    MenuItem2                                        : TMenuItem;
    MenuItem4                                        : TMenuItem;
    MenuItem6                                        : TMenuItem;
    MI_Delete_All_Groups                             : TMenuItem;
    MI_Goto_First_Object                             : TMenuItem;
    MI_Goto_Last_Object                              : TMenuItem;
    MI_Delete_Without_Children                       : TMenuItem;
    OPD_Add_Mask_Template                            : TOpenPictureDialog;
    OpenGLControl2                                   : TOpenGLControl;
    PageControl1                                     : TPageControl;
    Panel1                                           : TPanel;
    P_AnimK_Custom_Panel                             : TPanel;
    P_SGrid                                          : TPanel;
    P_RGrid                                          : TPanel;
    P_Dynamics_Prop                                  : TPanel;
    P_Save_Load_Prop                                 : TPanel;
    P_Map_Editor                                     : TPanel;
    P_Cycloid                                        : TPanel;
    P_Epicycloid                                     : TPanel;
    P_Rose                                           : TPanel;
    P_Play_Anim                                      : TPanel;
    P_Spline_Freehand_Settings                       : TPanel;
    P_Spline_Freehand                                : TPanel;
    P_Spray                                          : TPanel;
    P_Spline_Template_List                           : TPanel;
    P_Object_Properties                              : TPanel;
    P_Spline_Points                                  : TPanel;
    P_Spline_Edges                                   : TPanel;
    P_Spline_Templates_Properties                    : TPanel;
    P_Spline_Points_Rectangle_Thickness              : TPanel;
    P_Animation_Buttons                              : TPanel;
    P_Add_Actor                                      : TPanel;
    P_Optimization_Prop                              : TPanel;
    P_Edges_Prop                                     : TPanel;
    P_Drawing_Prop                                   : TPanel;
    P_Points_Prop                                    : TPanel;
    P_Objects_Tags                                   : TPanel;
    P_Scene_Tree                                     : TPanel;
    P_Inner_Subgraph1                                : TPanel;
    P_Outer_Subgraph                                 : TPanel;
    PM_Unfold_And_Align_Image                        : TPopupMenu;
    Panel2                                           : TPanel;
    Panel3                                           : TPanel;
    Panel4                                           : TPanel;
    Panel5                                           : TPanel;
    Panel6                                           : TPanel;
    P_Spline_Points_Rectangle_Inner_Rectangle        : TPanel;
    P_Spline_Edges_Line                              : TPanel;
    P_Spline_Templates                               : TPanel;
    P_Select_Texture_Region                          : TPanel;
    P_Tag_Properties                                 : TPanel;
    P_UV_Packing                                     : TPanel;
    Panel8                                           : TPanel;
    Panel9                                           : TPanel;
    PM_Drawing_Buttons                               : TPopupMenu;
    P_Draw_Custom_Panel                              : TPanel;
    P_Inner_Subgraph                                 : TPanel;
    P_Selective_Deletion                             : TPanel;
    P_Load_Save_Clear                                : TPanel;
    P_Drawing_Buttons                                : TPanel;
    P_Text                                           : TPanel;
    P_Brush                                          : TPanel;
    P_Spline                                         : TPanel;
    P_Select_Points                                  : TPanel;
    P_Transform_Ops                                  : TPanel;
    P_Image_Editor                                   : TPanel;
    P_2D_Operations_Automatic                        : TPanel;
    P_Align_Hot_Keys                                 : TPanel;
    P_UV_Operations                                  : TPanel;
    P_UV_Attributes                                  : TPanel;
    RB_Spline_Adaptive                               : TRadioButton;
    RB_Spline_Constant                               : TRadioButton;
    RB_Spline_None                                   : TRadioButton;
    SB_Map_Editor                                    : TSpeedButton;
    SB_RGrid                                         : TSpeedButton;
    SB_SGrid                                         : TSpeedButton;
    SB_RGrid_Color                                   : TSpeedButton;
    SB_Tag_Properties                                : TScrollBox;
    SB_Text_Select_Font                              : TSpeedButton;
    SB_Spline                                        : TSpeedButton;
    SB_Spline_Template_Superellipse                  : TSpeedButton;
    SB_Add_Actor                                     : TSpeedButton;
    SB_Brush                                         : TSpeedButton;
    SB_Brush4                                        : TSpeedButton;
    SB_Brush5                                        : TSpeedButton;
    SB_Image_List                                    : TScrollBox;
    SB_Selected_Points_Select_Color                  : TSpeedButton;
    SB_Load_Image                                    : TSpeedButton;
    SB_Inner_Subgraph_Select_Color                   : TSpeedButton;
    SB_Reset_Pivot2                                  : TSpeedButton;
    SB_Save_Image                                    : TSpeedButton;
    SB_Clear_Scene                                   : TSpeedButton;
    SB_Outer_Subgraph_Select_Color                   : TSpeedButton;
    SB_Select_Texture_Region                         : TSpeedButton;
    SB_Move_Pivot_To_Point                           : TSpeedButton;
    SB_Spline_Edges_Color                            : TSpeedButton;
    SB_Spline_Edges_Show                             : TSpeedButton;
    SB_Spline_Edges_Color_FallOff                    : TSpeedButton;
    SB_Spline_Points_Color                           : TSpeedButton;
    SB_Spline_Points_Show                            : TSpeedButton;
    SB_Spline_Edges_Color_Random                     : TSpeedButton;
    SB_Spline_Points_Color_Random                    : TSpeedButton;
    SB_Spline_Points_Color_FallOff                   : TSpeedButton;
    SB_Spray                                         : TSpeedButton;
    SB_StatusBar1                                    : TStatusBar;
    SB_Text                                          : TSpeedButton;
    SB_Select_Points                                 : TSpeedButton;
    SB_Play_Anim                                     : TSpeedButton;
    SB_Object_Properties                             : TScrollBox;
    SB_Unfold_Image_Window                           : TSpeedButton;
    CB_Brush_Mode                                    : TComboBox;
    CCB_2D_Operations_Automatic                      : TCheckComboBox;
    FSE_Brush_Fall_Off                               : TFloatSpinEdit;
    FSE_Width                                        : TFloatSpinEdit;
    FSE_Height                                       : TFloatSpinEdit;
    FSE_Angle                                        : TFloatSpinEdit;
    GB_Size                                          : TGroupBox;
    GB_Angle                                         : TGroupBox;
    L_Brush_Size                                     : TLabel;
    L_Brush_Hardness                                 : TLabel;
    L_Brush_Fall_Off                                 : TLabel;
    L_Brush_Mode                                     : TLabel;
    L_Label1                                         : TLabel;
    L_Axis_U                                         : TLabel;
    L_Axis_V                                         : TLabel;
    L_Angle                                          : TLabel;
    L_Edit_Mode                                      : TLabel;
    L_Width                                          : TLabel;
    L_Height                                         : TLabel;
    MI_Add_Group                                     : TMenuItem;
    MI_Remove_Object                                 : TMenuItem;
    MenuItem3                                        : TMenuItem;
    MI_Group_Objects                                 : TMenuItem;
    MI_Select_All                                    : TMenuItem;
    MI_Fold_Selected                                 : TMenuItem;
    MI_Unfold_Selected                               : TMenuItem;
    MI_Show_Hints                                    : TMenuItem;
    PC_Image_Editor                                  : TPageControl;
    PC_PageControl3                                  : TPageControl;
    P_Splitter5                                      : TPanel;
    PM_Scene_Tree                                    : TPopupMenu;
    RB_Points                                        : TRadioButton;
    RB_Polygons                                      : TRadioButton;
    RB_Edges                                         : TRadioButton;
    RG_Edit_Mode                                     : TRadioGroup;
    SB_2D_Operations                                 : TScrollBox;
    SB_Original_Texture_Size                         : TSpeedButton;
    SB_Drawing                                       : TScrollBox;
    SB_Visibility_Grid                               : TSpeedButton;
    SB_Visibility_Collider                           : TSpeedButton;
    SB_Visibility_Snap_Grid                          : TSpeedButton;
    SB_Visibility_Show_All                           : TSpeedButton;
    SB_Visibility_Spline                             : TSpeedButton;
    SB_Visibility_Texture                            : TSpeedButton;
    SB_Visibility_Actor                              : TSpeedButton;
    SB_TreeView_Object_Tags                          : TScrollBox;
    SB_AnimK                                         : TScrollBox;
    SE_Brush_Hardness1                               : TSpinEdit;
    SE_Brush_Hardness2                               : TSpinEdit;
    SE_Brush_Radius1                                 : TSpinEdit;
    SE_Brush_Radius2                                 : TSpinEdit;
    SE_Count_X                                       : TSpinEdit;
    SE_Count_Y                                       : TSpinEdit;
    SE_Cycloid_Loops_Count                           : TSpinEdit;
    SE_Cycloid_Points_Count                          : TSpinEdit;
    SE_Cycloid_Radius                                : TSpinEdit;
    SE_Rose_Angle                                    : TSpinEdit;
    SE_Rose_Points_Count                             : TSpinEdit;
    SE_Rose_Radius                                   : TSpinEdit;
    SE_Epicycloid_Rotation                           : TSpinEdit;
    SE_Epicycloid_Angle                              : TSpinEdit;
    SE_Rose_Rotation                                 : TSpinEdit;
    SE_Spline_Edges_Points_Radius                    : TSpinEdit;
    SE_Spline_Edges_Width                            : TSpinEdit;
    SE_Epicycloid_Points_Count                       : TSpinEdit;
    SE_Epicycloid_Petals_Count                       : TSpinEdit;
    SE_Epicycloid_Radius                             : TSpinEdit;
    SE_Spline_Edges_Dash_Length                      : TSpinEdit;
    SE_Spline_Points_Rectangle_Thikness_Left         : TSpinEdit;
    SE_Spline_Points_Rectangle_Inner_Rectangle_Width : TSpinEdit;
    SE_Spline_Points_Count                           : TSpinEdit;
    SE_Spline_Points_Rectangle_Thikness_Top          : TSpinEdit;
    SE_Spline_Points_Rectangle_Thikness_Right        : TSpinEdit;
    SE_Spline_Points_Rectangle_Thikness_Bottom       : TSpinEdit;
    SE_Spline_Points_Rectangle_Inner_Rectangle_Height: TSpinEdit;
    SE_Spline_Pts_Freq                               : TSpinEdit;
    SE_Brush_Radius                                  : TSpinEdit;
    SE_Brush_Hardness                                : TSpinEdit;
    SE_Spline_Bitmap_Width                           : TSpinEdit;
    SE_Spline_Bitmap_Height                          : TSpinEdit;
    SE_Select_Points_Bucket_Size                     : TSpinEdit;
    SB_Spline_Template_Cycloid                       : TSpeedButton;
    SB_Spline_Template_Epicycloid                    : TSpeedButton;
    SB_Spline_Template_Rose                          : TSpeedButton;
    SB_Spline_Template_Spiral                        : TSpeedButton;
    SE_Object_Properties_Parallax_Shift              : TSpinEdit;
    SE_Spline_Spray_Radius                           : TSpinEdit;
    S_Splitter0                                      : TSplitter;
    S_Splitter1                                      : TSplitter;
    S_Splitter2                                      : TSplitter;
    S_Splitter3                                      : TSplitter;
    S_Splitter4                                      : TSplitter;
    S_Splitter6                                      : TSplitter;
    S_Splitter7                                      : TSplitter;
    S_TreeView_Splitter                              : TSplitter;
    TB_Speed                                         : TTrackBar;
    T_Logo1                                          : TTimer;
    T_Logo2                                          : TTimer;
    T_Logo3                                          : TTimer;
    T_Menu                                           : TTimer;
    T_Game                                           : TTimer;
    TS_AnimK                                         : TTabSheet;
    TS_Outer_Subgraph                                : TTabSheet;
    TS_Inner_Subgraph                                : TTabSheet;
    TS_Selected_Points                               : TTabSheet;
    TS_Greedy2                                       : TTabSheet;
    TS_Hybride                                       : TTabSheet;
    TS_Physical                                      : TTabSheet;
    TS_Greedy1                                       : TTabSheet;
    TS_1_order_Isomorphic                            : TTabSheet;
    TS_p_order_Isomorphic                            : TTabSheet;
    BB_Reset_All_Values                              : TBitBtn;
    BB_Reset_Pivot                                   : TBitBtn;
    TS_File                                          : TTabSheet;
    TS_Draw                                          : TTabSheet;
    MI_Close_All                                     : TMenuItem;
    OpenPictureDialog1                               : TOpenPictureDialog;
    SavePictureDialog1                               : TSavePictureDialog;
    BB_Set_All_Values                                : TBitBtn;
    CD_Select_Color                                  : TColorDialog;
    FSE_Coord_U                                      : TFloatSpinEdit;
    FSE_Coord_V                                      : TFloatSpinEdit;
    GB_Move                                          : TGroupBox;
    MainMenu1                                        : TMainMenu;
    MI_3D_Viewer                                     : TMenuItem;
    MI_Hot_Keys                                      : TMenuItem;
    MI_System_Info                                   : TMenuItem;
    MI_Setings                                       : TMenuItem;
    MI_View                                          : TMenuItem;
    MI_Help                                          : TMenuItem;
    MI_File                                          : TMenuItem;
    MI_Save_As                                       : TMenuItem;
    MI_Open                                          : TMenuItem;
    MI_Exit                                          : TMenuItem;
    OpenDialog1                                      : TOpenDialog;
    PB_ProgressBar1                                  : TProgressBar;
    SaveDialog1                                      : TSaveDialog;
    T_Game_Loop                                      : TTimer;
    TrayIcon1                                        : TTrayIcon;
    TV_Scene_Tree                                    : TTreeView;

    {F_MainForm}
    procedure BB_Add_TilemapClick                                    (      sender           :TObject);
    procedure BB_Add_SpriteClick                                     (      sender           :TObject);
    procedure BB_GenerateClick                                       (      sender           :TObject);
    procedure BB_Load_FrameClick                                     (      sender           :TObject);
    procedure BB_Spline_Templates_RightClick                         (      sender           :TObject);
    procedure BB_Spline_Templates_LeftClick                          (      sender           :TObject);
    procedure BB_Use_MagicClick                                      (      sender           :TObject);
    procedure Button1Click                                           (      sender           :TObject);
    procedure CB_Cycloid_Direction_XSelect                           (      sender           :TObject);
    procedure CB_Cycloid_Direction_YSelect                           (      sender           :TObject);
    procedure CB_Dynamics_StyleSelect                                (      sender           :TObject);
    procedure CB_Epicycloid_HypocycloidChange                        (      sender           :TObject);
    procedure CB_Select_Points_Background_StyleSelect                (      sender           :TObject);
    procedure CB_Spline_Byte_ModeChange                              (      sender           :TObject);
    procedure CB_Spline_Edges_ShapeSelect                            (      sender           :TObject);
    procedure CB_Spline_Edges_Show_BoundsChange                      (      sender           :TObject);
    procedure CB_Spline_Hidden_Line_EliminationChange                (      sender           :TObject);
    procedure CB_Spline_Lazy_RepaintChange                           (      sender           :TObject);
    procedure CB_Spline_Invert_OrderChange                           (      sender           :TObject);
    procedure CB_Spline_Edges_LODChange                              (      sender           :TObject);
    procedure CB_Spline_Edges_StyleSelect                            (      sender           :TObject);
    procedure CB_Spline_On_Out_Of_WindowChange                       (      sender           :TObject);
    procedure CB_Spline_On_Scale_DownChange                          (      sender           :TObject);
    procedure CB_Spline_Points_ShapeSelect                           (      sender           :TObject);
    procedure CB_Spline_Points_Show_BoundsChange                     (      sender           :TObject);
    procedure CB_Spline_Points_StyleSelect                           (      sender           :TObject);
    procedure FormMouseMove                                          (      sender           :TObject;
                                                                            shift            :TShiftState;
                                                                            x,y              :integer);
    procedure FormMouseDown                                          (      sender           :TObject;
                                                                            button           :TMouseButton;
                                                                            shift            :TShiftState;
                                                                            x,y              :integer);
    procedure FormMouseUp                                            (      sender           :TObject;
                                                                            button           :TMouseButton;
                                                                            shift            :TShiftState;
                                                                            x,y              :integer);
    procedure FormDblClick                                           (      sender           :TObject);
    procedure FormPaint                                              (      sender           :TObject);
    procedure FormMouseWheelDown                                     (      sender           :TObject;
                                                                            shift            :TShiftState;
                                                                            mousepos         :TPoint;
                                                                      var   handled          :boolean);
    procedure FormMouseWheelUp                                       (      sender           :TObject;
                                                                            shift            :TShiftState;
                                                                            mousepos         :TPoint;
                                                                      var   handled          :boolean);
    procedure FormKeyPress                                           (      sender           :TObject;
                                                                      var   key              :char);
    procedure FormKeyDown                                            (      sender           :TObject;
                                                                      var   key              :word;
                                                                            shift            :TShiftState);
    procedure FormKeyUp                                              (      sender           :TObject;
                                                                      var   key              :word;
                                                                            shift            :TShiftState);
    procedure FormMouseEnter                                         (      sender           :TObject);
    procedure FormMouseLeave                                         (      sender           :TObject);
    procedure FormCreate                                             (      sender           :TObject);
    procedure FormActivate                                           (      sender           :TObject);
    procedure FormDestroy                                            (      sender           :TObject);
    procedure FormDropFiles                                          (      sender           :TObject;
                                                                      const file_names       :array of string);
    procedure FormResize                                             (      sender           :TObject);
    procedure FSE_Rose_Petals_CountChange                            (      sender           :TObject);
    procedure FSE_Cycloid_CurvatureChange                            (      sender           :TObject);
    procedure I_Frame_ListMouseDown                                  (      sender           :TObject;
                                                                            button           :TMouseButton;
                                                                            shift            :TShiftState;
                                                                            x,y              :integer);
    procedure I_Frame_ListMouseEnter                                 (      sender           :TObject);
    procedure MI_Align_Image_On_Inner_Window_ResizeClick             (      sender           :TObject);

    {Menu Items}
    procedure MI_OpenClick                                           (      sender           :TObject);
    procedure MI_ExitClick                                           (      sender           :TObject);
    procedure MI_3D_ViewerClick                                      (      sender           :TObject);
    procedure MI_Object_InfoClick                                    (      sender           :TObject);
    procedure MI_Full_ScreenClick                                    (      sender           :TObject);
    procedure MI_Save_AsClick                                        (      sender           :TObject);
    procedure MI_TrancparencyClick                                   (      sender           :TObject);
    procedure MI_Hot_KeysClick                                       (      sender           :TObject);
    procedure MI_System_InfoClick                                    (      sender           :TObject);
    procedure MI_Button_Style_1Click                                 (      sender           :TObject);
    procedure MI_Button_Style_2Click                                 (      sender           :TObject);
    procedure OpenGLControl2Click                                    (      sender           :TObject);
    procedure P_2D_Operations_AutomaticMouseEnter                    (      sender           :TObject);
    procedure P_2D_Operations_AutomaticMouseLeave                    (      sender           :TObject);
    procedure P_Animation_ButtonsMouseMove                           (      sender           :TObject;
                                                                            shift            :TShiftState;
                                                                            x,y              :integer);
    procedure P_Animation_ButtonsPaint                               (      sender           :TObject);
    procedure P_Drawing_ButtonsMouseMove                             (      sender           :TObject;
                                                                            shift            :TShiftState;
                                                                            x,y              :integer);
    procedure P_Dynamics_PropMouseEnter                              (      sender           :TObject);
    procedure P_Dynamics_PropMouseLeave                              (      sender           :TObject);
    procedure P_Optimization_PropMouseEnter                          (      sender           :TObject);
    procedure P_Optimization_PropMouseLeave                          (      sender           :TObject);
    procedure P_Edges_PropMouseEnter                                 (      sender           :TObject);
    procedure P_Edges_PropMouseLeave                                 (      sender           :TObject);
    procedure P_Drawing_PropMouseEnter                               (      sender           :TObject);
    procedure P_Drawing_PropMouseLeave                               (      sender           :TObject);
    procedure P_Points_PropMouseEnter                                (      sender           :TObject);
    procedure P_Points_PropMouseLeave                                (      sender           :TObject);
    procedure P_Save_Load_PropMouseEnter                             (      sender           :TObject);
    procedure P_Save_Load_PropMouseLeave                             (      sender           :TObject);
    procedure P_Spline_EdgesMouseEnter                               (      sender           :TObject);
    procedure P_Spline_EdgesMouseLeave                               (      sender           :TObject);
    procedure P_Spline_FreehandMouseEnter                            (      sender           :TObject);
    procedure P_Spline_FreehandMouseLeave                            (      sender           :TObject);
    procedure P_Spline_PointsMouseEnter                              (      sender           :TObject);
    procedure P_Spline_PointsMouseLeave                              (      sender           :TObject);
    procedure P_Spline_TemplatesMouseEnter                           (      sender           :TObject);
    procedure P_Spline_TemplatesMouseLeave                           (      sender           :TObject);
    procedure P_Spline_Template_ListMouseEnter                       (      sender           :TObject);
    procedure P_Spline_Template_ListMouseLeave                       (      sender           :TObject);
    procedure P_Spline_Template_ListMouseWheelDown                   (      sender           :TObject;
                                                                            shift            :TShiftState;
                                                                            mousepos         :TPoint;
                                                                      var   handled          :boolean);
    procedure P_Spline_Template_ListMouseWheelUp                     (      sender           :TObject;
                                                                            shift            :TShiftState;
                                                                            mousepos         :TPoint;
                                                                      var   handled          :boolean);
    procedure P_Spline_Template_ListPaint                            (      sender           :TObject);
    procedure RB_Spline_AdaptiveChange                               (      sender           :TObject);
    procedure SB_Add_ActorClick                                      (      sender           :TObject);
    procedure SB_Map_EditorClick                                     (      sender           :TObject);
    procedure SB_RGridClick                                          (      sender           :TObject);
    procedure SB_RGrid_ColorClick                                    (      sender           :TObject);
    procedure SB_SGridClick                                          (      sender           :TObject);
    procedure SB_SplineClick                                         (      sender           :TObject);
    procedure SB_Spline_TemplateClick                                (      sender           :TObject);
    procedure SB_Play_AnimClick                                      (      sender           :TObject);
    procedure SB_Select_Texture_RegionClick                          (      sender           :TObject);
    procedure SB_Spline_Edges_ColorClick                             (      sender           :TObject);
    procedure SB_Spline_Edges_Color_FallOffClick                     (      sender           :TObject);
    procedure SB_Spline_Edges_Color_RandomClick                      (      sender           :TObject);
    procedure SB_Spline_Edges_ShowClick                              (      sender           :TObject);
    procedure SB_Spline_Points_ColorClick                            (      sender           :TObject);
    procedure SB_Spline_Points_Color_FallOffClick                    (      sender           :TObject);
    procedure SB_Spline_Points_Color_RandomClick                     (      sender           :TObject);
    procedure SB_Spline_Points_ShowClick                             (      sender           :TObject);
    procedure SB_Object_PropertiesMouseEnter                         (      sender           :TObject);
    procedure SB_Object_PropertiesMouseLeave                         (      sender           :TObject);
    procedure SB_Tag_PropertiesMouseEnter                            (      sender           :TObject);
    procedure SB_Tag_PropertiesMouseLeave                            (      sender           :TObject);
    procedure SB_Text_Select_FontClick                               (      sender           :TObject);
    procedure SB_TreeView_Object_TagsMouseWheelDown                  (      sender           :TObject;
                                                                            shift            :TShiftState;
                                                                            mousepos         :TPoint;
                                                                      var   handled          :boolean);
    procedure SB_TreeView_Object_TagsMouseWheelUp                    (      sender           :TObject;
                                                                            shift            :TShiftState;
                                                                            mousepos         :TPoint;
                                                                      var   handled          :boolean);
    procedure SE_Cycloid_Loops_CountChange                           (      sender           :TObject);
    procedure SE_Cycloid_Points_CountChange                          (      sender           :TObject);
    procedure SE_Cycloid_RadiusChange                                (      sender           :TObject);
    procedure SE_Epicycloid_AngleChange                              (      sender           :TObject);
    procedure SE_Epicycloid_Petals_CountChange                       (      sender           :TObject);
    procedure SE_Epicycloid_Points_CountChange                       (      sender           :TObject);
    procedure SE_Epicycloid_RadiusChange                             (      sender           :TObject);
    procedure SE_Epicycloid_RotationChange                           (      sender           :TObject);
    procedure SE_Object_Properties_Parallax_ShiftChange              (      sender           :TObject);
    procedure SE_Rose_AngleChange                                    (      sender           :TObject);
    procedure SE_Rose_Points_CountChange                             (      sender           :TObject);
    procedure SE_Rose_RadiusChange                                   (      sender           :TObject);
    procedure SE_Rose_RotationChange                                 (      sender           :TObject);
    procedure SE_Spline_Edges_WidthChange                            (      sender           :TObject);
    procedure SE_Spline_Points_CountChange                           (      sender           :TObject);
    procedure SE_Spline_Points_Rectangle_Inner_Rectangle_HeightChange(      sender           :TObject);
    procedure SE_Spline_Points_Rectangle_Inner_Rectangle_WidthChange (      sender           :TObject);
    procedure SE_Spline_Points_Rectangle_Thikness_BottomChange       (      sender           :TObject);
    procedure SE_Spline_Points_Rectangle_Thikness_LeftChange         (      sender           :TObject);
    procedure SE_Spline_Points_Rectangle_Thikness_RightChange        (      sender           :TObject);
    procedure SE_Spline_Points_Rectangle_Thikness_TopChange          (      sender           :TObject);
    procedure SE_Spline_Pts_FreqKeyDown                              (      sender           :TObject;
                                                                      var   key              :word;
                                                                            shift            :TShiftState);
    procedure SE_Spline_Spray_RadiusChange                           (      sender           :TObject);

    {Buttons}
    procedure S_Splitter0ChangeBounds                                (      sender           :TObject);
    procedure S_Splitter2ChangeBounds                                (      sender           :TObject);
    procedure S_Splitter3ChangeBounds                                (      sender           :TObject);
    procedure S_Splitter6ChangeBounds                                (      sender           :TObject);
    procedure S_Splitter7ChangeBounds                                (      sender           :TObject);
    procedure S_Splitter1Moved                                       (      sender           :TObject);
    procedure S_Splitter2Moved                                       (      sender           :TObject);
    procedure S_Splitter3Moved                                       (      sender           :TObject);
    procedure BB_Bottom_Splitter_To_LeftClick                        (      sender           :TObject);
    procedure BB_Bottom_Splitter_To_RightClick                       (      sender           :TObject);
    procedure BB_Set_Value_UClick                                    (      sender           :TObject);
    procedure BB_Reset_Value_UClick                                  (      sender           :TObject);
    procedure BB_Set_Value_UMouseLeave                               (      sender           :TObject);
    procedure BB_Set_Value_VClick                                    (      sender           :TObject);
    procedure BB_Reset_Value_VClick                                  (      sender           :TObject);
    procedure BB_Set_All_ValuesClick                                 (      sender           :TObject);
    procedure BB_Reset_All_ValuesClick                               (      sender           :TObject);
    procedure SB_Move_Pivot_To_PointClick                            (      sender           :TObject);
    procedure BB_Reset_PivotClick                                    (      sender           :TObject);
    procedure BB_Save_UVClick                                        (      sender           :TObject);
    procedure BB_Reset_UVClick                                       (      sender           :TObject);
    procedure CCB_2D_Operations_AutomaticItemChange                  (      sender           :TObject;
                                                                            aindex           :integer);
    procedure CCB_2D_Operations_AutomaticGetItems                    (      sender           :TObject);
    procedure CCB_2D_Operations_AutomaticSelect                      (      sender           :TObject);
    procedure SE_Align_2D_Points_Precision_UMouseEnter               (      sender           :TObject);
    procedure SE_Align_2D_Points_Precision_VMouseEnter               (      sender           :TObject);
    procedure SE_Align_2D_Points_Precision_UChange                   (      sender           :TObject);
    procedure SE_Align_2D_Points_Precision_VChange                   (      sender           :TObject);
    procedure SE_Align_2D_Points_Precision_UMouseLeave               (      sender           :TObject);
    procedure SE_Align_2D_Points_Precision_VMouseLeave               (      sender           :TObject);
    procedure CB_Align_2D_Points_Show_Snap_GridChange                (      sender           :TObject);
    procedure CB_Align_2D_Points_Snap_Grid_VisibilityChange          (      sender           :TObject);
    procedure TB_SpeedChange                                         (      sender           :TObject);
    procedure TB_SpeedClick                                          (      sender           :TObject);
    procedure TextureListItemMouseDown                               (      sender           :TObject;
                                                                            button           :TMouseButton;
                                                                            shift            :TShiftState;
                                                                            x,y              :integer);
    procedure SB_Load_ImageClick                                     (      sender           :TObject);
    procedure SB_Save_ImageClick                                     (      sender           :TObject);
    procedure SB_Clear_SceneClick                                    (      sender           :TObject);
    procedure BB_Delete_SelectedClick                                (      sender           :TObject);
    procedure BB_Delete_AllClick                                     (      sender           :TObject);
    procedure SB_Unfold_Image_WindowClick                            (      sender           :TObject);
    procedure SB_Unfold_Image_WindowMouseLeave                       (      sender           :TObject);
    procedure SB_Original_Texture_SizeClick                          (      sender           :TObject);
    procedure SB_Original_Texture_SizeMouseLeave                     (      sender           :TObject);
    procedure SB_Background_ColorClick                               (      sender           :TObject);
    procedure SB_Grid_ColorClick                                     (      sender           :TObject);
    procedure SB_Spline_ColorClick                                   (      sender           :TObject);
    procedure SB_IS_Graph_ColorClick                                 (      sender           :TObject);
    procedure SB_UV_Mesh_ColorClick                                  (      sender           :TObject);
    procedure SB_Snap_Grid_ColorClick                                (      sender           :TObject);
    procedure I_Visibility_PanelMouseLeave                           (      sender           :TObject);
    procedure I_Visibility_PanelPaint                                (      sender           :TObject);
    procedure SB_Visibility_TextureMouseEnter                        (      sender           :TObject);
    procedure SB_Visibility_GridMouseEnter                           (      sender           :TObject);
    procedure SB_Visibility_Snap_GridMouseEnter                      (      sender           :TObject);
    procedure SB_Visibility_SplineMouseEnter                         (      sender           :TObject);
    procedure SB_Visibility_ActorMouseEnter                          (      sender           :TObject);
    procedure SB_Visibility_ColliderMouseEnter                       (      sender           :TObject);
    procedure SB_Visibility_TextureClick                             (      sender           :TObject);
    procedure SB_Visibility_GridClick                                (      sender           :TObject);
    procedure SB_Visibility_SplineClick                              (      sender           :TObject);
    procedure SB_Visibility_ColliderClick                            (      sender           :TObject);
    procedure SB_Visibility_ActorClick                               (      sender           :TObject);
    procedure SB_Visibility_Snap_GridClick                           (      sender           :TObject);
    procedure SB_Visibility_Show_AllClick                            (      sender           :TObject);
    procedure TS_DrawMouseWheelDown                                  (      sender           :TObject;
                                                                            shift            :TShiftState;
                                                                            mousepos         :TPoint;
                                                                      var   handled          :boolean);
    procedure TS_DrawMouseWheelUp                                    (      sender           :TObject;
                                                                            shift            :TShiftState;
                                                                            mousepos         :TPoint;
                                                                      var   handled          :boolean);
    procedure P_Load_Save_ClearPaint                                 (      sender           :TObject);
    procedure P_Drawing_ButtonsPaint                                 (      sender           :TObject);
    procedure SB_BrushClick                                          (      sender           :TObject);
    procedure SB_SprayClick                                          (      sender           :TObject);
    procedure SB_TextClick                                           (      sender           :TObject);
    procedure CB_Spline_ModeSelect                                   (      sender           :TObject);
    procedure SE_Spline_Pts_FreqChange                               (      sender           :TObject);
    procedure CB_Spline_TypeSelect                                   (      sender           :TObject);
    procedure CB_Spline_Connect_EndsChange                           (      sender           :TObject);
    procedure FSE_Spline_Simplification_AngleChange                  (      sender           :TObject);
    procedure CB_Spline_Edges_Anti_AliasingChange                    (      sender           :TObject);
    procedure SB_Select_PointsClick                                  (      sender           :TObject);
    procedure CB_Select_Points_Selection_ModeSelect                  (      sender           :TObject);
    procedure SB_Outer_Subgraph_Select_ColorClick                    (      sender           :TObject);
    procedure CB_Select_Points_Line_StyleSelect                      (      sender           :TObject);
    procedure CB_Select_Points_Clip_StyleSelect                      (      sender           :TObject);
    procedure SE_Select_Points_Bucket_SizeChange                     (      sender           :TObject);
    procedure SB_Inner_Subgraph_Select_ColorClick                    (      sender           :TObject);
    procedure SB_Selected_Points_Select_ColorClick                   (      sender           :TObject);
    procedure CB_Select_Points_Show_Selected_EdgesChange             (      sender           :TObject);
    procedure CB_Select_Points_Show_BoundsChange                     (      sender           :TObject);
    procedure TV_Scene_TreeDblClick                                  (      sender           :TObject);
    procedure TV_Scene_TreeEditing                                   (      sender           :TObject;
                                                                            node             :TTreeNode;
                                                                      var   allowedit        :boolean);
    procedure TV_Scene_TreeEditingEnd                                (      sender           :TObject;
                                                                            node             :TTreeNode;
                                                                            cancel           :boolean);
    procedure TV_Scene_TreeKeyDown                                   (      sender           :TObject;
                                                                      var   key              :word;
                                                                            shift            :TShiftState);
    procedure TV_Scene_TreeKeyPress                                  (      sender           :TObject;
                                                                      var   key              :char);
    procedure T_Game_LoopTimer                                       (      sender           :TObject);
    procedure Tic                                                    (      sender           :TObject;
                                                                      var   done             :boolean);
    procedure T_Logo1Timer                                           (      sender           :TObject);
    procedure T_Logo2Timer                                           (      sender           :TObject);
    procedure T_Logo3Timer                                           (      sender           :TObject);
    procedure T_MenuTimer                                            (      sender           :TObject);
    procedure T_GameTimer                                            (      sender           :TObject);

    {Miscellaneous}
    procedure VisibilityChange                                       (      set_visibility   :boolean); inline; {$ifdef Linux}[local];{$endif}
    procedure KeysEnable;                                                                               inline; {$ifdef Linux}[local];{$endif}
    procedure KeysDisable;                                                                              inline; {$ifdef Linux}[local];{$endif}

    procedure SplinesTemplatesNamesInit                              (      sln_var_         :TCurve);

    {TrayIcon}
    procedure TrayIcon1Click                                         (      sender           :TObject);

    {Scene Tree}
    constructor Create                                               (      theowner         :TComponent); override;
    procedure MI_Add_GroupClick                                      (      sender           :TObject);
    procedure MI_Remove_ObjectClick                                  (      sender           :TObject);
    procedure MI_Group_ObjectsClick                                  (      sender           :TObject);
    procedure MI_Delete_Without_ChildrenClick                        (      sender           :TObject);
    procedure MI_Delete_All_GroupsClick                              (      sender           :TObject);
    procedure MI_Select_AllClick                                     (      sender           :TObject);
    procedure MI_Fold_SelectedClick                                  (      sender           :TObject);
    procedure MI_Unfold_SelectedClick                                (      sender           :TObject);
    procedure MI_Goto_First_ObjectClick                              (      sender           :TObject);
    procedure MI_Goto_Last_ObjectClick                               (      sender           :TObject);
    procedure TV_Scene_TreeDragOver                                  (      sender,
                                                                            source           :TObject;
                                                                            x,y              :integer;
                                                                            state            :TDragState;
                                                                      var   accept           :boolean);
    procedure TV_Scene_TreeMouseDown                                 (      sender           :TObject;
                                                                            button           :TMouseButton;
                                                                            shift            :TShiftState;
                                                                            x,y              :integer);
    procedure TV_Scene_TreeDragDrop                                  (      sender,
                                                                            source           :TObject;
                                                                            x,y              :integer);
    procedure S_TreeView_SplitterChangeBounds                        (      sender           :TObject);

    private
      procedure OnMove(var message:TWMMove); message WM_MOVE; // Обработчик перемещения формы

    strict private

    protected

    strict protected

    public

    published

  end; {$endregion}
  PF_MainForm        =^TF_MainForm;

  {Saved Up Points----}
  TSavedUpPts        =class {$region -fold}
    public
      var
      {TODO}
        saved_up_pts    : TPtPosFArr;
        {TODO}
        saved_up_pts_cnt: TColor;
        {TODO}
      procedure SavePts (const target_pts_arr      :TPtPosFArr;
                         const target_pts_cnt      :TColor;
                         var   saved_up_pts_arr    :TPtPosFArr;
                         var   saved_up_pts_arr_cnt:TColor); {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure ResetPts(var   target_pts_arr      :TPtPosFArr;
                         const saved_up_pts_arr    :TPtPosFArr;
                         const saved_up_pts_arr_cnt:TColor;
                               proc_ptr            :TProc0); {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PSavedUpPts        =^TSavedUpPts;

  {Surface Drawing----}
  TSurf              =class {$region -fold}
    public
      need_repaint           : boolean;
      {Main  Layer------------------} {$region -fold}
        {main bitmap}
        srf_bmp              : Graphics.TBitmap;
        test_bmp             : Graphics.TBitmap;
        {main bitmap handle}
        srf_bmp_ptr          : PInteger;
        test_bmp_ptr         : PInteger;
        {main bitmap bounding rectangle}
        srf_bmp_rct          : TPtRect;
        {background color}
        bg_color             : TColor; {$endregion}
      {Lower Layer(Before Selection)} {$region -fold}
        {lower layer(before selection) bitmap}
        low_bmp              : Graphics.TBitmap;
        {lower layer(before selection) bitmap handle}
        low_bmp_ptr          : PInteger;
        {drawing of lower layer(before selection)}
        low_bmp_draw         : boolean; {$endregion}
      {Lower Layer(After  Selection)} {$region -fold}
        {lower layer(after selection)}
        low_bmp2             : Graphics.TBitmap;
        {lower layer(after selection) bitmap handle}
        low_bmp2_ptr         : PInteger;
        {drawing of lower layer(after selection)}
        low_bmp2_draw        : boolean; {$endregion}
      {Buffer for Baking Rotatable Sprites}
      rot_arr                : TColorArr;
      rot_arr_ptr            : PInteger;
      rot_arr_width          : TColor;
      rot_arr_height         : TColor;
      {inner window bitmap bounding rectangle}
      inn_wnd_rct            : TPtRect;
      {array of stored drawing styles(blending effects)}
      drawing_style          : array[0..4] of TDrawingStyle;
      {background post-process effect}
      bkg_style              : TBackgroundStyle;
      {world axis}
      world_axis_bmp         : TFastImage;
      world_axis             : TPtPos;
      world_axis_shift       : TPtPos;
      world_axis_draw        : boolean;
      {Speed Multiplier}
      parallax_shift         : TPtPos;
      mov_dir                : TMovingDirection;
      {TODO}
      scl_dif                : integer;
      {scale direction}
      scl_dir                : TSclDir;
      {UI}
      inner_window_ui_visible: boolean;
      {TODO}
      dir_a                  : boolean;
      dir_d                  : boolean;
      dir_w                  : boolean;
      dir_s                  : boolean;
      {create class instance}
      constructor Create           (         w,h           :TColor);                      {$ifdef Linux}[local];{$endif}
      {destroy class instance}
      destructor  Destroy;                                                      override; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure MainBmpRectCalc;                                                  inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure MainBmpSizeCalc;                                                  inline; {$ifdef Linux}[local];{$endif}
      {set new sizes of bitmaps and arrays}
      procedure MainBmpArrsCalc;                                                  inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure InnerWindowDraw    (color                  :TColor);              inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure BmpSettings        (bmp_dst                :Graphics.TBitmap;
                                    pen_color              :TColor;
                                    pen_mode               :TPenMode=pmCopy;
                                    brush_style            :TBrushStyle=bsSolid); inline; {$ifdef Linux}[local];{$endif}

      {TODO}
      procedure MainBmpToLowerBmp;                                                inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure MainBmpToLowerBmp2;                                               inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure LowerBmpToMainBmp;                                                inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure LowerBmp2ToMainBmp;                                               inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure FilBkgndObj        (constref bkgnd_ind     :TColor);              inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure SetBkgnd           (constref bkgnd_ptr     :PInteger;
                                    constref bkgnd_width,
                                             bkgnd_height  :TColor;
                                    constref rct_clp       :TPtRect);             inline; {$ifdef Linux}[local];{$endif}
      {Events Queue}
      {Get Handles---------------------------------}
      procedure GetHandles;                                                       inline; {$ifdef Linux}[local];{$endif}
      {World Axis: Drawing-------------------------}
      procedure WorldAxisDraw;                                                    inline; {$ifdef Linux}[local];{$endif}
      {Align Spline: Calculation-------------------}
      procedure AlnSplineCalc;                                                    inline; {$ifdef Linux}[local];{$endif}
      {Select Pivot: Calculation-------------------}
      procedure SelectPivotCalc;                                                  inline; {$ifdef Linux}[local];{$endif}
      {Select Pivot: Drawing-----------------------}
      procedure SelectPivotDraw;                                                  inline; {$ifdef Linux}[local];{$endif}
      {Unselect Pivot: Drawing---------------------}
      procedure UnselectPivotDraw;                                                inline; {$ifdef Linux}[local];{$endif}
      {Selected Subgraph: Drawing------------------}
      procedure OuterSubgraphDraw;                                                inline; {$ifdef Linux}[local];{$endif}
      {Selected Subgraph: Drawing------------------}
      procedure InnerSubgraphDraw;                                                inline; {$ifdef Linux}[local];{$endif}
      {Selected Points  : Drawing------------------}
      procedure SelectdPointsDraw;                                                inline; {$ifdef Linux}[local];{$endif}
      {Add Spline: Calculation---------------------}
      procedure AddSplineCalc;                                                    inline; {$ifdef Linux}[local];{$endif}
      {Add Spline: Hidden Lines--------------------}
      procedure AddSplineHdLn;                                                    inline; {$ifdef Linux}[local];{$endif}
      {Add Spline: Drawing-------------------------}
      procedure AddSplineDraw;                                                    inline; {$ifdef Linux}[local];{$endif}
      {Add Tile Map: Calculation-------------------}
      procedure AddTileMapCalc;                                                   inline; {$ifdef Linux}[local];{$endif}
      {Scale Background: Calculation---------------}
      procedure SclBckgdCalc;                                                     inline; {$ifdef Linux}[local];{$endif}
      {Scale Spline: Calculation-------------------}
      procedure SclSplineCalc;                                                    inline; {$ifdef Linux}[local];{$endif}
      {Repaint Splines with Hidden Lines-----------}
      procedure RepSplineHdLn;                                                    inline; {$ifdef Linux}[local];{$endif}
      {Repaint Spline: Drawing---------------------}
      procedure RepSplineDraw0;                                                   inline; {$ifdef Linux}[local];{$endif}
      procedure RepSplineDraw1;                                                   inline; {$ifdef Linux}[local];{$endif}
      {Duplicated Points: Drawing------------------}
      procedure DupPtsDraw;                                                       inline; {$ifdef Linux}[local];{$endif}
      {World Axis: Reset Background Settings-------}
      procedure WAxSetBckgd;                                                      inline; {$ifdef Linux}[local];{$endif}
      {Selected Subgraph: Drawing------------------}
      procedure SelectedSubgrtaphDraw;                                            inline; {$ifdef Linux}[local];{$endif}
      {Sel. Tools Marker: Reset Background Settings}
      procedure STMSetBckgd;                                                      inline; {$ifdef Linux}[local];{$endif}
      {Actors: Reset Background Settings-----------}
      procedure ActSetBckgd;                                                      inline; {$ifdef Linux}[local];{$endif}
      {TimeLine: Reset Background Settings---------}
      procedure TLnSetBkgnd;                                                      inline; {$ifdef Linux}[local];{$endif}
      {Cursors: Reset Background Settings----------}
      procedure CurSetBkgnd;                                                      inline; {$ifdef Linux}[local];{$endif}
      {Background Post-Processing------------------}
      procedure BkgPP;                                                            inline; {$ifdef Linux}[local];{$endif}
      {Grid Post-Processing------------------------}
      procedure GrdPP;                                                            inline; {$ifdef Linux}[local];{$endif}
      {Main Render Procedure}
      procedure MainDraw;                                                                 {$ifdef Linux}[local];{$endif}
      procedure EventGroupsCalc    (var      arr           :TBool2Arr;
                                             event_group   :TEventGroupEnum);             {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PSurf              =^TSurf;

  {Main Layer Instance}
  TSurfInst          =class {$region -fold}
    public
      {TODO}
      bmp_rect: TPtRect;
      {create class instance}
      constructor Create(w,h:TColor); {$ifdef Linux}[local];{$endif}
      {destroy class instance}
      destructor  Destroy; override;  {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PSurfInst          =^TSurfInst;

  {Texture------------}
  TTex               =class {$region -fold}
    public
      {list of loaded textures}
      tex_list                  : TPictArr;
      {buffer, which contains loaded texture}
      loaded_picture            : TPicture;
      {texture layer}
      tex_bmp                   : Graphics.TBitmap;
      {texture bmp handle}
      tex_bmp_ptr               : PInteger;
      {texture bmp bounding rectangle}
      tex_bmp_rct_pts           : TPtPosFArr;
      {source bounding box for loaded texture}
      tex_bmp_rct_origin_pts    : TPtPosFArr;
      {size of texture preview in texure list}
      tex_list_item_size        : TColor;
      {checking if texture is enabled}
      is_tex_enabled            : boolean;
      {TODO}
      moving                    : boolean;
      {TODO}
      scaling                   : boolean;
      {TODO}
      rotation                  : boolean;
      {create class instance}
      constructor Create   (         w,h       :TColor);          {$ifdef Linux}[local];{$endif}
      {destroy class instance}
      destructor  Destroy;                              override; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure LoadTexture;                              inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure TexToBmp   (         rect_dst  :TPtRect;
                                     canvas_dst:TCanvas); inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure AlignPictureToCenter;                     inline; {$ifdef Linux}[local];{$endif}
      {fill background texture}
      procedure FilBkTexObj(constref bktex_ind :TColor);  inline; {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PTex               =^TTex;

  {Grid---------------}
  TRGrid             =class {$region -fold}
    public
      class var
        {TODO}
        rgrid_color: TColor;
        {grid density}
        rgrid_dnt  : integer;
      {create class instance}
      constructor Create   (         w,h          :TColor);          {$ifdef Linux}[local];{$endif}
      {destroy class instance}
      destructor  Destroy;                                 override; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure RGridToBmp (constref pvt          :TPtPosF;
                            constref bmp_dst_ptr  :PInteger;
                            constref bmp_dst_width:TColor;
                                     rct_clp      :TPtRect); inline; {$ifdef Linux}[local];{$endif}
      procedure FilRGridObj(constref rgrid_ind    :TColor);  inline; {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PRGrid             =^TRGrid;

  {Snap Grid----------}
  TSGrid             =class {$region -fold}
    public
      class var
        {snap grid color}
        sgrid_color: TColor;
        {grid density}
        sgrid_dnt  : integer;
        {TODO}
        align_pts  : boolean;
        {create class instance}
      constructor Create   (         w,h             :TColor);          {$ifdef Linux}[local];{$endif}
      {destroy class instance}
      destructor  Destroy;                                    override; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure SGridToBmp (constref pvt             :TPtPosF;
                            constref bmp_dst_ptr     :PInteger;
                            constref bmp_dst_width   :TColor;
                                     rct_clp         :TPtRect); inline; {$ifdef Linux}[local];{$endif}
      procedure FilSGridObj(constref sgrid_ind       :TColor);  inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure AlignPts   (var   pts                :TPtPosFArr;
                            const sel_pts_inds       :TColorArr;
                            const pts_cnt,sel_pts_cnt:TColor);          {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PSGrid             =^TSGrid;

  {Spline-------------}
  TCurve             =class {$region -fold}
    public
      {spline edges bounding rectangles buffers}
      rct_eds_img_arr        : TFLnArr;
      rct_eds_big_img        : TFastLine;
      rct_eds_useless_fld_arr: TColorArr;
      {spline points bounding rectangles buffers}
      rct_pts_img_arr        : TFLnArr;
      rct_pts_big_img        : TFastLine;
      rct_pts_useless_fld_arr: TColorArr;
      {spline edges buffers}
      eds_img_arr            : TFLnArr;
      eds_big_img            : TFastLine;
      eds_useless_fld_arr    : TColorArr;
      {spline points buffers}
      pts_img_arr            : TFLnArr;
      pts_big_img            : TFastLine;
      pts_useless_fld_arr    : TColorArr;
      {duplicated points}
      dup_pts_arr            : TPtPos2Arr;
      {spline global properties which will be shown on panel of spline properties in editor}
      global_prop            : TCurveProp;
      {Spline Template List} {$region -fold}
        FmlSplineObj         : array[byte] of TProc7;
        sln_tlt_nam_arr1     : array[byte] of string;
        sln_tlt_nam_arr2     : array[byte] of PByteBool;
        // index of minimal parameter(left/top) of "Spline Teamplates"(spline type:formula) buttons:
        sln_tlt_fst_it_ind   : byte;
        // index of current button down:
        cur_tlt_dwn_btn_ind  : smallint; {$endregion}
      {spline saved up points}
      sln_saved_up_pts_var   : TSavedUpPts;
      {TODO}
      btn_glyph_origin       : Graphics.TBitmap;
      {TODO}
      btn_temp_glyph         : Graphics.TBitmap;
      {TODO}
      tex_on_sln_tmp_bmp     : Graphics.TBitmap;
      {TODO}
      tex_on_sln             : TPicture;
      {array of ponts for intermediate calculations(when points areadded)}
      sln_pts_add            : TPtPosFArr;
      {(partial points sums) частичные суммы точек сплайнов}
      partial_pts_sum        : TColorArr;
      {(array of counts of spline objects points) массив числа точек сплайнов}
      sln_obj_pts_cnt        : TColorArr;
      {does spline have selected points:
      0 - no points selected;
      1 - there are selected points in outer subgraph;
      2 - there are selected points in inner subgraph;
      3 - there are selected points in outer and inner subgraphs;
      4 - there is a single selected point}
      has_sel_pts            : T1Byte1Arr;
      {spline_points}
      sln_pts                : TPtPosFArr;
      {formula spline points (dummy preview in editor)}
      fml_pts                : TPtPosFArr;
      {(array of spline objects indices) массив индексов сплайнов}
      sln_obj_ind            : TColorArr;
      {set value to point:
      0 - inner spline object point;
      1 - first spline object point;
      2 - last  spline object point;
      3 - spline object has single point}
      fst_lst_sln_obj_pts    : TEnum0Arr;
      {does point have an edge:
      -1 - point doesnt have edge;
      0  - point has         edge}
      has_edge               : TShIntArr;
      {TODO}
      rct_bnd_ind_arr        : array of TEnum2Arr;
      {all splines bounding rectangle intersected with inner window}
      sln_obj_all_rct_vis    : TRect;
      {spline objects count}
      sln_obj_cnt            : TColor;
      {spline points count}
      sln_pts_cnt            : TColor;
      {spline points count on addition}
      sln_pts_cnt_add        : TColor;
      {spline edges count}
      sln_eds_cnt            : TColor;
      {points increment used in interjacent calculations}
      pts_inc                : TColor;
      {detect, if spline drawing is happening}
      draw_spline            : boolean;
      {detect, if spline was changed}
      sln_changed            : boolean;
      {detect, if there is at least one spline with property local_prop.hid_ln_elim in True}
      has_hid_ln_elim_sln    : boolean;
      {repaint first time on hidden-line elimination}
      rep_hid_ln_elim_first  : boolean;
      {linked list for "Add Point"}
      first_item,p1,p2       : PFList;
      {Init. Part}
      constructor Create                   (constref w,h             :TColor;
                                            constref bkgnd_ptr       :PInteger;
                                            constref bkgnd_width,
                                                     bkgnd_height    :TColor);                {$ifdef Linux}[local];{$endif}
      destructor  Destroy;                                                          override; {$ifdef Linux}[local];{$endif}
      {compress primitive surface}
      procedure PrimitiveComp              (constref spline_ind      :TColor;
                                            constref pmt_var_ptr,
                                                     pmt_big_var_ptr :PFastLine;
                                                     pmt_bld_stl     :TDrawingStyle); inline; {$ifdef Linux}[local];{$endif}
      {add point: drawing}
      procedure AddPoint                   (constref x,y             :integer;
                                            constref bmp_dst_ptr     :PInteger;
                                            constref bmp_dst_width   :TColor;
                                            var      color_info      :TColorInfo;
                                            constref rct_clp         :TPtRect;
                                            var      add_spline_calc_:boolean;
                                                     sleep_          :boolean=False); inline; {$ifdef Linux}[local];{$endif}
      {calculation of spline rectangle}
      procedure RctSplineRct0              (constref spline_ind      :TColor;
                                            var      rct_out_,
                                                     rct_ent_        :TRect);                 {$ifdef Linux}[local];{$endif}
      procedure RctSplineRct1              (constref spline_ind      :TColor;
                                            var      rct_out_,
                                                     rct_ent_        :TRect);                 {$ifdef Linux}[local];{$endif}
      procedure RctSplineRct2              (constref spline_ind      :TColor;
                                            var      rct_out_,
                                                     rct_ent_        :TRect);                 {$ifdef Linux}[local];{$endif}
      procedure RctSplineRctEds            (constref spline_ind      :TColor;
                                            constref rct_out_,
                                                     rct_ent_        :TRect);                 {$ifdef Linux}[local];{$endif}
      procedure RctSplineRctPts            (constref spline_ind      :TColor;
                                            constref rct_out_,
                                                     rct_ent_        :TRect);                 {$ifdef Linux}[local];{$endif}
      procedure RctSplineEds               (constref spline_ind      :TColor;
                                            constref rct_out_,
                                                     rct_ent_        :TRect);                 {$ifdef Linux}[local];{$endif}
      procedure RctSplinePts               (constref spline_ind      :TColor;
                                            constref rct_out_,
                                                     rct_ent_        :TRect);                 {$ifdef Linux}[local];{$endif}
      procedure RctSplineObj0              (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      procedure RctSplineObj1              (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      {calculation of all splines rectangles}
      procedure RctSplineAll0              (constref start_ind,
                                                     end_ind         :TColor);        inline; {$ifdef Linux}[local];{$endif}
      procedure RctSplineAll1              (constref start_ind,
                                                     end_ind         :TColor);        inline; {$ifdef Linux}[local];{$endif}
      procedure RctSplineAll2              (constref start_ind,
                                                     end_ind         :TColor);        inline; {$ifdef Linux}[local];{$endif}
      procedure RctSplineAll3              (constref start_ind,
                                                     end_ind         :TColor);        inline; {$ifdef Linux}[local];{$endif}
      {calculation of spline on addition}
      procedure AddSplineObj               (constref rct_out         :TPtRect);               {$ifdef Linux}[local];{$endif}
      {add spline bounding rectangle to spline edges buffer into clipped region}
      procedure AddSplineRctEds            (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      {add spline bounding rectangle to spline points buffer into clipped region}
      procedure AddSplineRctPts            (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      {add spline edges to spline edges buffer into clipped region}
      procedure AddSplineEds0              (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      procedure AddSplineEds1              (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      procedure AddSplineEds2              (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      procedure AddSplineEds3              (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      procedure AddSplineEds4              (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      procedure AddSplineEds5              (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      procedure AddSplineEds6              (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      procedure AddSplineEds7              (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      {add spline points to spline points buffer into clipped region}
      procedure AddSplinePts0              (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      procedure AddSplinePts1              (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      procedure AddSplinePts2              (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      procedure AddSplinePts3              (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      procedure AddSplinePts4              (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      procedure AddSplinePts5              (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      procedure AddSplinePts6              (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      procedure AddSplinePts7              (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      {add spline duplicated points on specified buffer(dup_pts_arr)}
      procedure AddSplineDupPts0           (constref spline_ind      :TColor);        inline; {$ifdef Linux}[local];{$endif}
      procedure AddSplineDupPts1           (constref spline_ind      :TColor);        inline; {$ifdef Linux}[local];{$endif}
      procedure AddSplineDupPts2           (constref spline_ind      :TColor);        inline; {$ifdef Linux}[local];{$endif}
      procedure AddSplineDupPts3           (constref spline_ind      :TColor);        inline; {$ifdef Linux}[local];{$endif}
      procedure AddSplineDupPtsAll         (constref start_ind,
                                                     end_ind         :TColor);        inline; {$ifdef Linux}[local];{$endif}
      {clear spline duplicated points on specified buffer(dup_pts_arr)}
      procedure ClrSplineDupPts0           (constref spline_ind      :TColor);        inline; {$ifdef Linux}[local];{$endif}
      procedure ClrSplineDupPts1           (constref spline_ind      :TColor);        inline; {$ifdef Linux}[local];{$endif}
      procedure ClrSplineDupPts2           (constref spline_ind      :TColor);        inline; {$ifdef Linux}[local];{$endif}
      procedure ClrSplineDupPts3           (constref spline_ind      :TColor);        inline; {$ifdef Linux}[local];{$endif}
      {clear all spline edges on spline edges  bounding rectangles buffer}
      procedure ClrSplineRctEds            (constref spline_ind      :TColor);        inline; {$ifdef Linux}[local];{$endif}
      {clear all spline edges on spline points bounding rectangles buffer}
      procedure ClrSplineRctPts            (constref spline_ind      :TColor);        inline; {$ifdef Linux}[local];{$endif}
      {clear all spline edges on spline edges buffers}
      procedure ClrSplineEds               (constref spline_ind      :TColor);        inline; {$ifdef Linux}[local];{$endif}
      {clear all spline points on spline points buffers}
      procedure ClrSplinePts               (constref spline_ind      :TColor);        inline; {$ifdef Linux}[local];{$endif}
      {clear all splines from start_ind to end_ind}
      procedure ClrSplineAll               (constref start_ind,
                                                     end_ind         :TColor);        inline; {$ifdef Linux}[local];{$endif}
      {create sprite of all spline edges and points bounding rectangles on spline edges  bounding rectangles buffer into clipped region}
      procedure CrtSplineRctEds            (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      {create sprite of all spline edges and points bounding rectangles on spline points bounding rectangles buffer into clipped region}
      procedure CrtSplineRctPts            (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      {create sprite of all spline edges on spline edges buffer into clipped region}
      procedure CrtSplineEds               (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      {create sprite of all spline points on spline points buffer into clipped region}
      procedure CrtSplinePts               (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      {create sprite of all spline edges and points from start_ind to end_ind}
      procedure CrtSplineAll0              (constref start_ind,
                                                     end_ind         :TColor);        inline; {$ifdef Linux}[local];{$endif}
      procedure CrtSplineAll1              (constref start_ind,
                                                     end_ind         :TColor);        inline; {$ifdef Linux}[local];{$endif}
      {fill all spline edges and points bounding rectangles on spline edges  bounding rectangles buffer into clipped region}
      procedure FilSplineRctEds            (constref spline_ind      :TColor);        inline; {$ifdef Linux}[local];{$endif}
      {fill all spline edges and points bounding rectangles on spline points bounding rectangles buffer into clipped region}
      procedure FilSplineRctPts            (constref spline_ind      :TColor);        inline; {$ifdef Linux}[local];{$endif}
      {fill all spline edges on spline edges buffer into clipped region}
      procedure FilSplineEds               (constref spline_ind      :TColor);        inline; {$ifdef Linux}[local];{$endif}
      {fill all spline points on spline points buffer into clipped region}
      procedure FilSplinePts               (constref spline_ind      :TColor);        inline; {$ifdef Linux}[local];{$endif}
      {fill spline object}
      procedure FilSplineObj               (constref spline_ind      :TColor);        inline; {$ifdef Linux}[local];{$endif}
      {fill all spline objects}
      procedure FilSplineAll               (constref start_ind,
                                                     end_ind         :TColor);        inline; {$ifdef Linux}[local];{$endif}
      {generate formula spline into specified area}
      procedure FmlSplineInit;                                                        inline; {$ifdef Linux}[local];{$endif}
      procedure FmlSplinePrev              (constref fml_pts_cnt     :TColor);        inline; {$ifdef Linux}[local];{$endif}
      procedure Cycloid                    (constref x,y             :integer);       inline; {$ifdef Linux}[local];{$endif}
      procedure Epicycloid                 (constref x,y             :integer);       inline; {$ifdef Linux}[local];{$endif}
      procedure Rose                       (constref x,y             :integer);       inline; {$ifdef Linux}[local];{$endif}
      procedure Spiral                     (constref x,y             :integer);       inline; {$ifdef Linux}[local];{$endif}
      procedure Superellipse               (constref x,y             :integer);       inline; {$ifdef Linux}[local];{$endif}
      {move spline edges bounding rectangles}
      procedure MovSplineRctEds            (constref spline_ind      :TColor;
                                            constref rct_dst         :TPtRect);       inline; {$ifdef Linux}[local];{$endif}
      {move spline points bounding rectangles}
      procedure MovSplineRctPts            (constref spline_ind      :TColor;
                                            constref rct_dst         :TPtRect);       inline; {$ifdef Linux}[local];{$endif}
      {move spline edges}
      procedure MovSplineEds0              (constref spline_ind      :TColor;
                                            constref rct_dst         :TPtRect);       inline; {$ifdef Linux}[local];{$endif}
      procedure MovSplineEds1              (constref spline_ind      :TColor;
                                            constref rct_dst         :TPtRect);       inline; {$ifdef Linux}[local];{$endif}
      procedure MovSplineEds2              (constref spline_ind      :TColor;
                                            constref rct_dst         :TPtRect);       inline; {$ifdef Linux}[local];{$endif}
      {move spline points}
      procedure MovSplinePts0              (constref spline_ind      :TColor;
                                            constref rct_dst         :TPtRect);       inline; {$ifdef Linux}[local];{$endif}
      procedure MovSplinePts1              (constref spline_ind      :TColor;
                                            constref rct_dst         :TPtRect);       inline; {$ifdef Linux}[local];{$endif}
      {move spline object}
      procedure MovSplineObj               (constref spline_ind      :TColor;
                                            constref rct_dst         :TPtRect);       inline; {$ifdef Linux}[local];{$endif}
      {move all spline objects}
      procedure MovSplineAll               (constref start_ind,
                                                     end_ind         :TColor;
                                            constref rct_dst         :TPtRect);       inline; {$ifdef Linux}[local];{$endif}
      {repaint spline edges  bounding rectangles on spline edges and points bounding rectangles buffer into clipped region}
      procedure RepSplineRctEds            (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      {repaint spline points bounding rectangles on spline edges and points bounding rectangles buffer into clipped region}
      procedure RepSplineRctPts            (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      {repaint spline edges}
      procedure RepSplineEds               (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      {repaint spline points}
      procedure RepSplinePts               (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      {set random color info.}
      procedure RndSplineCol               (var      local_prop      :TCurveProp;
                                            var      col,col_inv     :TColor;
                                            var      col_ptr         :PInteger;
                                            constref btn             :TSpeedButton);          {$ifdef Linux}[local];{$endif}
      {generate random spline into specified area}
      procedure RndSplineObj               (constref pt              :TPtPos;
                                            constref w,h             :TColor);                {$ifdef Linux}[local];{$endif}
      {drawing simplified spline edges on spline edges buffer into clipped region}
      procedure SmpSplineEds               (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
      {drawing simplified spline points on spline points buffer into clipped region}
      procedure SmpSplinePts               (constref spline_ind      :TColor);                {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PCurve             =^TCurve;

  {UV-----------------}
  TUV                =class {$region -fold}
    public
      {TODO}
      uv_drawing_style: TDrawingStyle;
      {TODO}
      uv_color        : TColor;
      {array of uv texture points(vertices)}
      uv_pts          : TPtPosFArr;
      {TODO}
      n_gons          : TColor;
      {TODO}
      triangles       : TColor;
      {TODO}
      quads           : TColor;
      {TODO}
      groups          : TColor;
      {create class instance}
      constructor Create(w,h:TColor); {$ifdef Linux}[local];{$endif}
      {destroy class instance}
      destructor  Destroy;  override; {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PUV                =^TUV;

  {Intersection Graph-}
  TISGraph           =class {$region -fold}
    public
      {TODO}
      is_graph_drawing_style: TDrawingStyle;
      {TODO}
      is_graph_color        : TColor;
      {array of intersection graph points}
      is_graph_pts          : TPtPosFArr;
      {create class instance}
      constructor Create(w,h:TColor); {$ifdef Linux}[local];{$endif}
      {destroy class instance}
      destructor  Destroy;  override; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure ISGraphCalc;  inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure ISGraphDraw;  inline; {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PISGraph           =^TISGraph;

  {Select Points------}
  TSelPts            =class {$region -fold}
    public
      {selection image:circle,rectangle etc.}
      sel_pts_big_img            : TFastLine;
      {outer subgraph edges}
      outer_subgraph_img         : TFastLine;
      {inner subgraph edges}
      inner_subgraph_img         : TFastLine;
      {subgraph indices arrays} {$region -fold}
        {TODO}
        outer_subgraph1          : TEdgeArr;
        outer_subgraph1_eds_cnt  : TColor;
        {TODO}
        outer_subgraph2          : TEdgeArr;
        outer_subgraph2_eds_cnt  : TColor;
        {TODO}
        outer_subgraph3          : TEdgeArr;
        outer_subgraph3_eds_cnt  : TColor;
        {TODO}
        inner_subgraph_          : TEdgeArr;
        inner_subgraph__eds_cnt  : TColor;
        {TODO}
        sl_pt_subgraph_          : TSlPtArr;
        sl_pt_subgraph__eds_cnt  : TColor; {$endregion}
      {is point of outer or inner subgraph:
      0 - point is not selected;
      1 - point is of outer subgraph;
      2 - point is of inner subgraph}
      out_or_inn_subgraph_pts    : T1Byte1Arr;
      {selected points indices}
      sel_pts_inds               : TColorArr;
      {is point selected}
      is_point_selected          : TBool1Arr;
      {is point duplicated}
      is_point_duplicated        : TBool1Arr;
      {is point in circle}
      is_point_in_circle         : TBool1Arr;
      {selected points bitmap}
      sel_bmp                    : Graphics.TBitmap;
      {selected points bitmap handle}
      sel_bmp_handle             : PInteger;
      {selected points bounding rectangle}
      sel_pts_rct                : TRect;
      {TODO}
      not_sel_pts_rct            : TPtRect;
      {TODO}
      bucket_rct                 : TPtRect;
      {TODO}
      bucket_rct_color           : TColor;
      {count of splines with selected points}
      sln_with_sel_pts_cnt       : TColor;
      {count of selected points}
      sel_pts_cnt                : TColor;
      {count of duplicated points}
      dup_pts_cnt                : TColor;
      {minimal index of selected object(spline)}
      sel_obj_min_ind            : TColor;
      {is an abstract object kind after spline which has selected points and minimal index}
      is_not_abst_obj_kind_after : boolean;
      {draw outer subgraph }
      draw_out_subgraph          : boolean;
      {draw inner subgraph }
      draw_inn_subgraph          : boolean;
      {draw selected points}
      draw_selected_pts          : boolean;
      {select points:expression}
      sel_pts                    : boolean;
      {fill bmp only without full repaint}
      fill_bmp_only              : boolean;
      {selection mode}
      sel_mode                   : TSelectionMode;
      {create class instance}
      constructor Create                        (constref w,h                :TColor;
                                                 constref bkgnd_ptr          :PInteger;
                                                 constref bkgnd_width,
                                                          bkgnd_height       :TColor;
                                                 var      rct_out            :TPtRect);               {$ifdef Linux}[local];{$endif}
      {destroy class instance}
      destructor  Destroy;                                                                  override; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure ChangeSelectionMode             (         item_ind           :TColor);        inline; {$ifdef Linux}[local];{$endif}
      {add circle}
      procedure AddCircleSelection;                                                           inline; {$ifdef Linux}[local];{$endif}
      {compress primitive surface}
      procedure PrimitiveComp                   (constref pmt_img_ptr        :PFastLine;
                                                          pmt_bld_stl        :TDrawingStyle); inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure CrtCircleSelection;                                                                   {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure FilSelPtsObj                    (constref x,y                :integer);       inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure MinimizeCircleSelection;                                                      inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure SelectAllPts                    (const    pts_cnt,
                                                          eds_cnt            :TColor);        inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure SelectedPtsRectDraw             (         cnv_dst            :TCanvas;
                                                          b_rct              :TRect;
                                                          color1,
                                                          color2             :TColor);        inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure SubgraphCalc                    (var      has_sel_pts        :T1Byte1Arr;
                                                 constref pts                :TPtPosFArr;
                                                 constref fst_lst_sln_obj_pts:TEnum0Arr;
                                                 constref obj_ind            :TColorArr;
                                                 constref sln_obj_cnt        :TColor;
                                                 constref sln_pts_cnt        :TColor);        inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure UnselectedPtsCalc0              (constref fst_lst_sln_obj_pts:TEnum0Arr;
                                                 var      pts                :TPtPosFArr;
                                                 constref pvt_pos_curr,
                                                          pvt_pos_prev       :TPtPosF);               {$ifdef Linux}[local];{$endif}
      procedure UnselectedPtsCalc1              (constref fst_lst_sln_obj_pts:TEnum0Arr;
                                                 var      pts                :TPtPosFArr;
                                                 constref pvt_pos_curr,
                                                          pvt_pos_prev       :TPtPosF);               {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure SelPtsIndsToFalse;                                                            inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure DuplicatedPtsCalc;                                                            inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure AdvancedClipCalc                (         pts                :TPtPosFArr;
                                                          pts_cnt            :TColor;
                                                          is_pt_marked       :TBool1Arr);             {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure DuplicatedPtsToBmp;                                                           inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure OuterSubgraphToBmp              (         x,y                :integer;
                                                 constref pvt                :TPtPosF;
                                                 var      pts                :TPtPosFArr;
                                                 constref bmp_dst_ptr        :PInteger;
                                                 constref rct_clp            :TPtRect);               {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure InnerSubgraphToBmp              (         x,y                :integer;
                                                 constref pvt                :TPtPosF;
                                                 var      pts                :TPtPosFArr;
                                                 constref bmp_dst_ptr        :PInteger;
                                                 constref rct_clp            :TPtRect);               {$ifdef Linux}[local];{$endif}                                                                                            inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure SelectdPointsToBmp              (         x,y                :integer;
                                                 constref pvt                :TPtPosF;
                                                 var      pts                :TPtPosFArr;
                                                 constref bmp_dst_ptr        :PInteger;
                                                 constref rct_clp            :TPtRect);               {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure SelPvtAndSplineEdsToBmp;                                                      inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure SelPtsIndsToBmp                 (var      pts                :TPtPosFArr);            {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PSelPts            =^TSelPts;

  {Pivot--------------}
  TPivot             =class {$region -fold}
    public
      sel_tls_mrk          : TFastImage;
      {TODO}
      pvt                  : TPtPosF;
      {TODO}
      pvt_origin           : TPtPosF;
      {TODO}
      pvt_draw_sel_eds_on  : TPtPosF;
      {TODO}
      pvt_draw_sel_eds_off : TPtPosF;
      {TODO}
      pvt_bmp              : Graphics.TBitmap;
      {TODO}
      pvt_mode             : TPivotMode;
      {TODO}
      pvt_marker_arr       : array[0..3] of Graphics.TBitmap;
      {TODO}
      pvt_marker_bmp       : TPortableNetworkGraphic;
      {TODO}
      pvt_marker           : TPtPos;
      {previous pivot}
      pvt_prev             : TPtPos;
      {mouse motion vector}
      mos_mot_vec          : TLnPos;
      {TODO}
      pvt_axis_rect        : TPtRect;
      {TODO}
      align_pivot          : TPtPos;
      {TODO}
      need_align_pivot_x   : boolean;
      {TODO}
      need_align_pivot_y   : boolean;
      {TODO}
      need_align_pivot_p   : boolean;
      need_align_pivot_p2  : boolean;
      {TODO}
      pvt_marker_draw      : boolean;
      {TODO}
      pvt_marker_left      : boolean;
      {TODO}
      pvt_marker_top       : boolean;
      {TODO}
      pvt_marker_right     : boolean;
      {TODO}
      pvt_marker_bottom    : boolean;
      {TODO}
      pvt_to_pt            : boolean;
      {TODO}
      pvt_to_pt_draw_pt    : boolean;
      {TODO}
      move_pvt             : boolean;
      {TODO}
      scale_pvt            : boolean;
      {TODO}
      move_pvt_to_pt_button: boolean;
      {create class instance}
      constructor Create(w,h:TColor);                                                       {$ifdef Linux}[local];{$endif}
      {destroy class instance}
      destructor  Destroy;                                                        override; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure SelectionToolsMarkerCreate;                                         inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure SelectionToolsMarkerDraw  (constref x,y:integer);                   inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure SetPivotAxisRect          (constref pt_rct           :TPtRect;
                                           constref margin           :TColor=10);   inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure PivotCalc                 (constref pts              :TPtPosFArr;
                                           constref sel_pts_inds     :TColorArr;
                                           constref sel_pts_cnt      :TColor);              {$ifdef Linux}[local];{$endif}
      {align pivot on axis X}
      procedure AlignPivotOnX             (     var x,y              :integer;
                                                    shift            :TShiftState); inline; {$ifdef Linux}[local];{$endif}
      {align pivot on axis Y}
      procedure AlignPivotOnY             (     var x,y              :integer;
                                                    shift            :TShiftState); inline; {$ifdef Linux}[local];{$endif}
      {align pivot on points}
      procedure AlignPivotOnP             (     var x,y              :integer;
                                                    shift            :TShiftState); inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure PivotToPoint              (         x,y              :integer;
                                           constref pts              :TPtPosFArr;
                                           constref pts_cnt          :TColor;
                                           constref crc_rad_sqr      :TColor);              {$ifdef Linux}[local];{$endif}
      procedure PivotToPoint              (         x,y              :integer;
                                           constref pts              :TPtPos2Arr;
                                           constref rct_clp          :TPtRect;
                                           constref arr_dst_width    :TColor;
                                           constref crc_rad          :TColor;
                                                    density          :TColor=1);            {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure SelectedPtsBmpPositionCalc(         x,y              :integer;
                                           var      sel_pts_rect     :TRect);       inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure SelectedPtsScalingCalc    (         x,y              :integer;
                                           var      pts              :TEdgeArr);            {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure SelectedPtsRotationCalc   (         x,y              :integer;
                                           var      pts              :TEdgeArr);            {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure IsPivotOutOfInnerWindow   (var      custom_rect      :TPtRect;
                                           constref pvt_             :TPtPosF);     inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure PivotMarkerDraw           (         cnv_dst          :TCanvas);     inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure PivotToPointDraw          (         cnv_dst          :TCanvas);     inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure PivotAxisDraw             (         cnv_dst          :TCanvas;
                                           constref custom_rct       :TPtRect;
                                           constref shift            :TPtPos);      inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure PivotBoundsDraw;                                                    inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure PivotAngleDraw;                                                     inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure PivotModeDraw             (         cnv_dst          :TCanvas);     inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure PivotDraw                 (constref shift            :TPtPos);      inline; {$ifdef Linux}[local];{$endif}
    end; {$endregion}
  PPivot             =^TPivot;

  {Circle Selection---}
  TCircSel           =class {$region -fold}
    public
      {TODO}
      crc_sel_col       : TColor;
      {TODO}
      crc_sel_rct       : TRect;
      {TODO}
      crc_rad_invalidate: integer;
      {TODO}
      crc_rad           : integer;
      {TODO}
      crc_rad_sqr       : integer;
      {TODO}
      draw_crc_sel      : boolean;
      {TODO}
      resize_crc_sel    : boolean;
      {TODO}
      only_fill         : boolean;
      {create class instance}
      constructor Create;                                                                      {$ifdef Linux}[local];{$endif}
      {destroy class instance}
      destructor  Destroy;                                                           override; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure CircleSelection              (x,y                           :integer;
                                              constref m_c_var              :TSurf;
                                              constref s_c_var              :TSelPts;
                                              constref pts                  :TPtPosFArr;
                                              constref pts_cnt              :TColor;
                                              constref sel_draw             :boolean=True);    {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure CircleSelectionModeDraw      (         x,y                  :integer;
                                              constref m_c_var              :TSurf);   inline; {$ifdef Linux}[local];{$endif}
      {TODO}
      procedure ResizeCircleSelectionModeDraw;                                         inline; {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PCircSel           =^TCircSel;

  {Brush Selection----}
  TBrushSel          =class {$region -fold}
    public
      {TODO}
      draw_brs_sel: boolean;
      {create class instance}
      constructor Create;                                        {$ifdef Linux}[local];{$endif}
      {destroy class instance}
      destructor  Destroy;                             override; {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PBrushSel          =^TBrushSel;

  {Rectangle Selection}
  TRectSel           =class {$region -fold}
    public
      {TODO}
      rct_sel  : TRect;
      {TODO}
      rct_width: integer;
      {create class instance}
      constructor Create;            {$ifdef Linux}[local];{$endif}
      {destroy class instance}
      destructor  Destroy; override; {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PRectSel           =^TRectSel;

  {TileMap Editor-----}
  TTlMap             =class {$region -fold}
    public
      tilemap_arr1       : TPictArr;
      tilemap_arr2       : TFastImageArr;
      tilemap_sprite_icon: TFastImage;
      {create class instance}
      constructor Create;                                                            {$ifdef Linux}[local];{$endif}
      {destroy class instance}
      destructor  Destroy;                                                 override; {$ifdef Linux}[local];{$endif}
      {create default icon for mask teamplate sprite}
      procedure  TileMapSpriteDefaultIconCreate;                             inline; {$ifdef Linux}[local];{$endif}
      {add mask template}
      procedure  AddTileMapObj                 (constref rct_out  :TPtRect); inline; {$ifdef Linux}[local];{$endif}
      {add mask template preview}
      procedure  AddTileMapPreview;                                          inline; {$ifdef Linux}[local];{$endif}
      {}
      procedure  FilTileMapObj                 (constref tlmap_ind:TColor);  inline; {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PTlMap             =^TTlMap;
(******************************************************************************)



(******************************* Global Variables *****************************)
var

  {General}
  F_MainForm                 : TF_MainForm;
  max_sprite_w_h_rct         : TPtRect;
  ini_var                    : TIniFile;
  {inner window margin}
  inn_wnd_mrg                : integer=1{0}{0};
  splitter_thickness         : integer=4{2}{1};
  status_bar_thickness       : integer=53;
  pp_iters_cnt               : integer=1;
  skip_invalidate            : byte   =0;
  move_with_child_form       : boolean;
  bottom_splitter_to_left    : boolean;
  bottom_splitter_to_right   : boolean;
  bucket_size_change         : boolean;
  align_picture_to_center    : boolean=False;
  full_screen                : boolean=True;
  splitters_arr              : array[0..7] of PInteger;

  {Scene Tree----------------------------------} {$region -fold}
  tex_list_item_pos_x        : integer;
  tex_list_item_pos_y        : integer; {$endregion}

  {Show Object---------------------------------} {$region -fold}
  // show objects array
  show_obj_arr               : array[0..10] of boolean;
  // show all objects(visibility list)
  show_all                   : boolean absolute show_obj_arr[0];
  // show texture(visibility list)
  show_tex                   : boolean absolute show_obj_arr[1];
  // show grid(visibility list)
  show_grid                  : boolean absolute show_obj_arr[2];
  // show snap grid(visibility list)
  show_snap_grid             : boolean absolute show_obj_arr[3];
  // show splines(visibility list)
  show_spline                : boolean absolute show_obj_arr[4];
  // show textures on splines
  show_tex_on_spline         : boolean absolute show_obj_arr[7];
  // show tile maps(visibility list)
  show_tile_map              : boolean absolute show_obj_arr[8];
  // show actors(visibility list)
  show_actor                 : boolean absolute show_obj_arr[9];
  // show colliders(visibility list)
  show_collider              : boolean absolute show_obj_arr[10]; {$endregion}

  {Show Bounding Rectangles--------------------} {$region -fold}
  // show bounding rectangles array
  show_b_rect_arr            : array[0..2] of boolean;
  // show spline points bounding rectangle 1
  show_spline_pts_b_rect_1   : boolean absolute show_b_rect_arr[0]{=True};
  // show spline points bounding rectangle 2
  show_spline_pts_b_rect_2   : boolean absolute show_b_rect_arr[1]{=True};
  // show selected points bounding rectangle
  show_selected_pts_b_rect   : boolean absolute show_b_rect_arr[2]{=True}; {$endregion}

  {Select Tools(checking of speed buttons down)} {$region -fold}
  // down buttons array
  down_arr                      : array[0..10] of boolean;
  // down button "Text"
  down_text_ptr                 : PByteBool;
  // down button "Brush"
  down_brush_ptr                : PByteBool;
  // down button "Spray"
  down_spray_ptr                : PByteBool;
  // down button "Spline"
  down_spline_ptr               : PByteBool;
  // down button "Select Points"
  down_select_points_ptr        : PByteBool;
  // down button "Select Points"
  down_select_texture_region_ptr: PByteBool;
  // down button "Regular Grid"
  down_rgrid_ptr                : PByteBool;
  // down button "Snap Grid"
  down_sgrid_ptr                : PByteBool;
  // down button "Play"
  down_play_anim_ptr            : PByteBool;
  // down button "Map Editor"
  down_map_editor_ptr           : PByteBool;
  // down button "Add Actor"
  down_add_actor_ptr            : PByteBool;
  {// down button "Text Event"
  down_add_text_event_ptr       : PByteBool;} {$endregion}

  {Calculation Flags---------------------------} {$region -fold}
  // calculation flags array
  calc_arr                   : array[0..100] of boolean;
  // do all layers bounding rectangles need to be calculated:
  main_bmp_rect_calc         : boolean absolute calc_arr[00];
  // do all layers bitmaps sizes need to be calculated?:
  main_bmp_size_calc         : boolean absolute calc_arr[01];
  // do specified arrays sizes need to be calculated(probably with calculation of appropriate bitmaps sizes):
  main_bmp_arrs_calc         : boolean absolute calc_arr[02];
  // get handles of all main buffers:
  main_bmp_hndl_calc         : boolean absolute calc_arr[03];
  // resize form:
  form_resize_calc           : boolean absolute calc_arr[04];
  // is canvas changed:
  change_canvas_calc         : boolean absolute calc_arr[05];
  // background post-processing:
  bkg_pp_calc                : boolean absolute calc_arr[06];
  // is cursor in inner window:
  drawing_area_enter_calc    : boolean absolute calc_arr[07];
  // does grid need to be calculated:
  grid_calc                  : boolean absolute calc_arr[08];
  // does snap grid need to be calculated:
  snap_grid_calc             : boolean absolute calc_arr[09];
  // calculate snap grid precision:
  snap_grid_pr_calc          : boolean absolute calc_arr[10];
  // is snap grid precision changed:
  snap_grid_precision_calc   : boolean absolute calc_arr[11];
  // add spline:
  add_spline_calc            : boolean absolute calc_arr[12];
  // is spline simplification angle changed:
  spline_smpl_angle_calc     : boolean absolute calc_arr[13];
  // connect ends of spline:
  connect_ends_calc          : boolean absolute calc_arr[14];
  // anti-aliasing:
  spline_aa_calc             : boolean absolute calc_arr[15];
  // does spline bounding rectangle need to be calculated:
  sel_tls_mrk_set_bckgd      : boolean absolute calc_arr[16];
  // reset background settings for actors:
  actor_set_bckgd            : boolean absolute calc_arr[17];
  // repaint all splines:
  repaint_spline_calc        : boolean absolute calc_arr[18];
  // scale all splines:
  spline_scale_calc          : boolean absolute calc_arr[19];
  // draw selected edges:
  sel_eds_draw_calc          : boolean absolute calc_arr[20];
  // reset background settings for timeline buttons:
  timeline_set_bkgnd         : boolean absolute calc_arr[21];
  // reset background settings for timeline buttons:
  cursors_set_bkgnd          : boolean absolute calc_arr[22];
  // timeline drawing:
  timeline_draw              : boolean absolute calc_arr[23];
  // cursor drawing:
  cursor_draw                : boolean absolute calc_arr[24];
  // does pivot need to be unselected:
  unselect_pivot_calc        : boolean absolute calc_arr[27];
  // is spliter position changed:
  splitter_pos_moved_calc    : boolean absolute calc_arr[28];
  // scale background:
  bckgd_scale_calc           : boolean absolute calc_arr[29];
  // scene drawing:
  fill_scene_calc            : boolean absolute calc_arr[30];
  // align points:
  align_pts_calc             : boolean absolute calc_arr[31];
  // calculate bounding rectangles:
  rectangles_calc            : boolean absolute calc_arr[32];
  // add spline         : hidden lines:
  add_hid_ln_calc            : boolean absolute calc_arr[33];
  // repaint all splines: hidden lines:
  repaint_spline_hid_ln_calc0: boolean absolute calc_arr[34];
  repaint_spline_hid_ln_calc1: boolean absolute calc_arr[35];
  repaint_spline_hid_ln_calc2: boolean absolute calc_arr[36];
  // reset background settings for world axis:
  world_axis_set_bckgd       : boolean absolute calc_arr[37];
  // lazy repaint:
  lazy_repaint_calc          : boolean absolute calc_arr[38];
  // add tile map:
  add_tlmap_calc             : boolean absolute calc_arr[39]; {$endregion}

  {Miscellaneous Expressions-------------------} {$region -fold}
  // expressions array
  exp_arr                    : array[0..2] of boolean;
  // selected_pts_count>0
  exp0                       : boolean absolute exp_arr[0];
  // selected_pts_count<>spline_pts_count
  exp1                       : boolean absolute exp_arr[1];
  // spline_pts_count>0
  exp2                       : boolean absolute exp_arr[2]; {$endregion}

  {Visibility Panel}
  visibility_panel_picture   : Graphics.TBitmap;
  show_visibility_panel      : boolean=True;
  show_obj_info              : boolean=True;
  show_tex_info              : boolean=True;

  {Buttons:Draw-} {$region -fold}
  prev_panel_draw            : TPanel;
  curr_panel_draw            : TPanel; {$endregion}

  {Buttons:AnimK} {$region -fold}
  prev_panel_animk           : TPanel;
  curr_panel_animk           : TPanel; {$endregion}

  {Main Layer}
  srf_var                    : TSurf;

  {Texture}
  tex_var                    : TTex;

  {Regular Grid}
  rgr_var                    : TRGrid;

  {Snap Grid}
  sgr_var                    : TSGrid;

  {Spline}
  sln_var                    : TCurve;

  {UV}
  uv_var                     : TUV;

  {Intersection Graph}
  isg_var                    : TISGraph;

  {Selected Points}
  sel_var                    : TSelPts;

  {Pivot}
  pvt_var                    : TPivot;

  {Circle Selection}
  crc_sel_var                : TCircSel;

  {Brush Selection}
  brs_sel_var                : TBrushSel;

  {Rectangle Selection}
  rct_sel_var                : TRectSel;

  {Map Editor}
  tlm_var                    : TTlMap;

  {Actors}
  add_actor_var              : TSurfInst;
  fast_actor_set_var         : TFastActorSet;
  img_lst_bmp                : Graphics.TBitmap;
  img_lst_bmp_ptr            : PInteger;

  {Physics}
  fast_physics_var           : TCollider;

  {Fluid}
  fast_fluid_var             : TFluid;

  {Scene Tree}
  obj_var                    : TSceneTree;
  source_node_x,source_node_y: integer;

  {Color Picker}
  pixel_color                : TColor;

  {Brush}
  custom_icon                : TPortableNetworkGraphic;
  PrevX,PrevY                : integer;
  draw_brush                 : boolean;

  {Spray}
  draw_spray                 : boolean;

  sc0,sc1                    : TPtPos;

  ncs_adv_clip_rect          : TRect;

  mouse_pos_x,mouse_pos_y    : integer;
  treeview_splitter_shift    : integer;

  P_TreeView_Attributes_Cells: TPanel;

  {Execution Time}
  exec_timer                 : TPerformanceTime;

  test_picture_color         : Graphics.TPicture;
  test_picture_alpha         : Graphics.TPicture;

  vec_x,vec_y                : integer;

  sln_sprite_counter_pos_arr : TColorArr;
  sln_sprite_counter_rad_arr : TColorArr;
  sln_sprite_counter_pow_arr : TColorArr;

  sprite_rect_arr            : TPtPosArr;
  useless_arr_               : T1Byte1Arr;
  useless_fld_arr_           : TColorArr;

  anim_play2                 : boolean;

  is_active                  : boolean=True;

  downtime_counter           : integer;
  downtime                   : integer=320;
  key_down_arr               : array[0..2] of word=(0,0,0);
  key_down                   : word;

  {TimeLine}
  // cursors:
  cur_arr                    : TFastImageArr;
  // buttons_background:
  bckgd_btn_arr              : TFastImageArr;
  // buttons icons:
  tmln_btn_arr               : TFastImageArr;
  // buttons positions:
  btn_pos_arr                : TPtPosArr;

  {Cursors}
  cur_pos                    : TPoint;

  {OpenGL Context}
  texture_id                 : TColor;
  buffer                     : Windows.BITMAP;

  {Physics Test}
  coll_arr                   : TColorArr;
  projectile_var             : TProjectile;
  projectile_arr             : array of TProjectile;

  {Test}
  angle                      : double=0;
  flood_fill_inc             : boolean;
  drs                        : byte;

  loop_cnt,angle_cnt         : TColor;
  rot_img_arr                : TFastImageArr;
  bounding_rct               : TPtRect;
  arr_test                   : TColorArr;

  {Game}



(******************************************************************************)



{forward declarations begin}(**************************************************)
{Miscellaneous}
{}
procedure SpeedButtonRepaint; inline; {$ifdef Linux}[local];{$endif}
procedure BtnColAndDown(constref spd_btn:TSpeedButton; var down_flag:boolean; color_down:TColor=NAV_SEL_COL_0; color_up:TColor=$00CBDAB1); inline; {$ifdef Linux}[local];{$endif}
procedure SelectionBounds(custom_bitmap:Graphics.TBitmap; custom_rect:TPtRect; custom_color:TColor; custom_width:integer);
procedure SelectionBoundsRepaint; inline; {$ifdef Linux}[local];{$endif}
{Check if Colors are Mask Color(clBlack) and Replace Them}
procedure IsObjColorAMaskColor; inline; {$ifdef Linux}[local];{$endif}
function  DwmIsCompositionEnabled(out pfEnabled:longbool): HRESULT; external 'Dwmapi.dll';
function  EnumDisplaySettingsA(lpszDeviceName:LPCSTR; iModeNum:DWORD; var lpDevMode:TDeviceModeA): BOOL; external 'user32';
procedure InvalidateInnerWindow; inline; {$ifdef Linux}[local];{$endif}
procedure InvalidateRegion(rct_dst:TRect); inline; {$ifdef Linux}[local];{$endif}
procedure MoveBorders; inline; {$ifdef Linux}[local];{$endif}
procedure Align3DViewer; inline; {$ifdef Linux}[local];{$endif}
procedure CustomCursor(X,Y:integer); inline; {$ifdef Linux}[local];{$endif}
procedure MainArraysDone; inline; {$ifdef Linux}[local];{$endif}
function  ObjectInfo0: string; inline; {$ifdef Linux}[local];{$endif}
procedure CheckDIB; inline; {$ifdef Linux}[local];{$endif}

{Scene Tree}
// calculate objects indices in object array:
procedure ObjIndsCalc;                                                inline; {$ifdef Linux}[local];{$endif}
// calculate objects indices in scene tree:
procedure ScTIndsCalc;                                                inline; {$ifdef Linux}[local];{$endif}
procedure CreateNodeData     (         node_with_data:TTreeNode;
                                       g_ind         :TColor);        inline; {$ifdef Linux}[local];{$endif}
procedure ClearNodeData      (         node_with_data:TTreeNode);     inline; {$ifdef Linux}[local];{$endif}
procedure DeleteSelectedNodes(         TV            :TTreeView);     inline; {$ifdef Linux}[local];{$endif}
procedure AddTagPanel        (constref ind           :integer);       inline; {$ifdef Linux}[local];{$endif}
procedure CreateNode         (         item_text1,
                                       item_text2    :ansistring;
                                       is_first_node :boolean=False); inline; {$ifdef Linux}[local];{$endif}

{Brush}
procedure BrushDraw(X,Y:integer); inline; {$ifdef Linux}[local];{$endif}

{Spray}
procedure SprayDraw(X,Y,r:integer; custom_color:TColor); inline; {$ifdef Linux}[local];{$endif}

{World Axis}
procedure WorldAxisCreate;                    inline; {$ifdef Linux}[local];{$endif}
procedure WorldAxisBmp(constref x,y:integer); inline; {$ifdef Linux}[local];{$endif}

{TimeLine}
procedure TimeLineButtonsCreate;                     inline; {$ifdef Linux}[local];{$endif}
procedure TimeLineButtonsDraw(constref x,y:integer); inline; {$ifdef Linux}[local];{$endif}

{Cursors}
procedure CursorsCreate;                                                inline; {$ifdef Linux}[local];{$endif}
procedure CursorDraw(constref x,y:integer; constref cur_ind:integer=0); inline; {$ifdef Linux}[local];{$endif}
procedure CursorDraw;                                                   inline; {$ifdef Linux}[local];{$endif}
{forward declarations end}(****************************************************)



(******************************* Camera Movement ******************************)

procedure MovLeft;                                   inline; {$ifdef Linux}[local];{$endif}
procedure FilLeft (constref bmp_dst_ptr   :PInteger;
                   constref bmp_dst_width,
                            bmp_dst_height:integer;
                   constref rct_dst       :TPtRect); inline; {$ifdef Linux}[local];{$endif}

procedure MovRight;                                  inline; {$ifdef Linux}[local];{$endif}
procedure FilRight(constref bmp_dst_ptr   :PInteger;
                   constref bmp_dst_width,
                            bmp_dst_height:integer;
                   constref rct_dst       :TPtRect); inline; {$ifdef Linux}[local];{$endif}

procedure MovUp;                                     inline; {$ifdef Linux}[local];{$endif}
procedure FilUp   (constref bmp_dst_ptr   :PInteger;
                   constref bmp_dst_width,
                            bmp_dst_height:integer;
                   constref rct_dst       :TPtRect); inline; {$ifdef Linux}[local];{$endif}

procedure MovDown;                                   inline; {$ifdef Linux}[local];{$endif}
procedure FilDown (constref bmp_dst_ptr   :PInteger;
                   constref bmp_dst_width,
                            bmp_dst_height:integer;
                   constref rct_dst       :TPtRect); inline; {$ifdef Linux}[local];{$endif}

(******************************************************************************)

implementation

uses
  model_viewer,Hot_Keys;  // Вызов View > 3D Viewer в меню редактора

{$R *.lfm}

{TF_MainForm}

// (Main Arrays Finalization) Очистка основных массивов:
{LI} {$region -fold}
procedure MainArraysDone; inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  {for i:=0 to spline_canvas_var.spline_obj_count-1 do
    FArrClear_1(spline_canvas_var.spline_edges_var[i].f_ln_arr1,spline_canvas_var.spline_edges_var[i].spline_obj_rect_vis.Width,spline_canvas_var.spline_edges_var[i].spline_obj_rect_vis.Height);
  FArrClear_0(selected_canvas_var.selected_pts_f_ln_var.f_ln_arr0,selected_canvas_var.selected_bmp.Width,selected_canvas_var.selected_bmp.Height);
  FArrClear_2(selected_canvas_var.selected_pts_f_ln_var.f_ln_arr2,selected_canvas_var.selected_bmp.Width,selected_canvas_var.selected_bmp.Height);
  FArrClear_0(selected_canvas_var.outer_subgraph_var.f_ln_arr0,main_canvas_var.lower_layer_bmp.Width,main_canvas_var.lower_layer_bmp.Height);
  FArrClear_1(selected_canvas_var.outer_subgraph_var.f_ln_arr1,selected_canvas_var.selected_bmp.Width,selected_canvas_var.selected_bmp.Height);
  FArrClear_2(selected_canvas_var.outer_subgraph_var.f_ln_arr2,main_canvas_var.lower_layer_bmp.Width,main_canvas_var.lower_layer_bmp.Height);
  FArrClear_1(selected_canvas_var.inner_subgraph_var.f_ln_arr1,selected_canvas_var.selected_bmp.Width,selected_canvas_var.selected_bmp.Height);
  tex_canvas_var.tex_list                               :=Nil;
  node_tex_inds                                         :=Nil;
  node_spline_inds                                      :=Nil;
  //spline_canvas_var.spline_saved_up_pts_var.saved_up_pts:=Nil;
  spline_canvas_var.spline_obj_pts_count                :=Nil;
  spline_canvas_var.spline_pts                          :=Nil;
  spline_canvas_var.first_last_spline_obj_pts           :=Nil;
  selected_canvas_var.is_point_selected                 :=Nil;
  selected_canvas_var.is_point_duplicated               :=Nil;
  selected_canvas_var.outer_subgraph1                   :=Nil;
  selected_canvas_var.outer_subgraph2                   :=Nil;
  selected_canvas_var.outer_subgraph3                   :=Nil;
  selected_canvas_var.inner_subgraph                    :=Nil;
  selected_canvas_var.selected_pts_indices              :=Nil;
  is_graph_canvas_var.is_graph_pts                      :=Nil;
  spline_obj_ind_inc                                    :=0;
  spline_canvas_var.spline_pts_count                    :=0;
  spline_canvas_var.spline_obj_count                    :=0;
  spline_canvas_var.pts_inc                             :=0;
  selected_canvas_var.selected_pts_count                :=0;
  selected_canvas_var.outer_subgraph1_edges_count       :=0;
  selected_canvas_var.outer_subgraph2_edges_count       :=0;
  selected_canvas_var.outer_subgraph3_edges_count       :=0;
  selected_canvas_var.inner_subgraph_edges_count        :=0;}
end; {$endregion}
{$endregion}

// (Object Info) Информация об обьекте:
{LI} {$region -fold}
function ObjectInfo0: string;                                                                     inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  info_arr: array[0..17] of string;
  i       : integer;
  low_lr_obj_cnt: integer;
  upp_lr_obj_cnt: integer;
begin

  Result:='';

  low_lr_obj_cnt:=obj_var.LowLrObjCntCalc;
  upp_lr_obj_cnt:=obj_var.obj_cnt-obj_var.LowLrObjCntCalc;

  if (obj_var<>Nil) then
    info_arr[00]:='Objects: '                                                          +InttoStr(obj_var.obj_cnt                  )+';';
  info_arr[01]:=#13+'Objects of lower layer: '                                         +IntToStr(low_lr_obj_cnt                   )+';';
  info_arr[02]:=#13+'Objects of upper layer: '                                         +IntToStr(upp_lr_obj_cnt                   )+';';
  info_arr[03]:=#13+'Groups: '                                                         +IntToStr(obj_var.group_cnt                )+';';
  info_arr[04]:=#13+'Actors: '                                                         +IntToStr(obj_var.actor_cnt                )+';';
  info_arr[05]:=#13+'  • Static: '                                                                                                 +';';
  info_arr[06]:=#13+'  • Dynamic: '                                                                                                +';';
  info_arr[07]:=#13+'  • Physical: '                                                                                               +';';
  info_arr[08]:=#13+'Particles: '                                                      +IntToStr(obj_var.prtcl_cnt                )+';';
  info_arr[09]:=#13+'Curves: '                                                         +IntToStr(obj_var.curve_cnt                )+';';
  if (sln_var<>Nil) then
    info_arr[10]:=#13+'  • Points: '                                                   +InttoStr(sln_var.sln_pts_cnt              )+';';
  if (sel_var<>Nil) then
    begin
      info_arr[11]:=#13+'    • Count of curve                  with selected points: ' +InttoStr(sel_var.sln_with_sel_pts_cnt     )+';';
      info_arr[12]:=#13+'    • Minimal index of curve          with selected points: ' +InttoStr(sel_var.sel_obj_min_ind          )+';';
      info_arr[13]:=#13+'    • Selected: '                                             +InttoStr(sel_var.sel_pts_cnt              )+';';
      if (sel_var.sel_pts_cnt=0) then
        info_arr[14]:=#13+'      • Is not abstract object          kind after: ;'
      else
        begin
          if sel_var.is_not_abst_obj_kind_after then
            info_arr[14]:=#13+'      • Is not abstract object          kind after: '    +'Yes;'
          else
            info_arr[14]:=#13+'      • Is not abstract object          kind after: '    +'No;'
        end;
      info_arr[15]:=#13+'    • Duplicated: '                                           +InttoStr(sel_var.dup_pts_cnt              )+';';
    end;
  if (sln_var<>Nil) then
    info_arr[16]:=#13+'  • Lines: '                                                    +InttoStr(sln_var.sln_eds_cnt              )+';';
  info_arr[17]:=#13+'Tile maps: '                                                      +IntToStr(obj_var.tlmap_cnt                )+';';

  for i:=0 to 17 do
    Result+=info_arr[i];

end; {$endregion}
procedure DrawObjectInfo0;                                                                        inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  F_MainForm.L_Object_Info.Caption:=ObjectInfo0;
end; {$endregion}
procedure DrawObjectInfo1(constref x,y:integer; bmp_dst:Graphics.TBitmap; constref text_:string); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  F_MainForm.L_Exec_Time_Info.Caption:=text_;
end; {$endregion}
procedure CheckDIB;                                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
{var
  h_d_c: HDC;}
begin
  {h_d_c:=F_MainForm.Canvas.Handle;}
  {F_MainForm.L_Log.Caption:=IntToStr(GetDeviceCaps(h_d_c,RC_STRETCHBLT));}
end; {$endregion}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.MI_Object_InfoClick(sender:TObject); {$region -fold}
begin
  L_Object_Info.Visible:=MI_Object_Info.Checked;
  show_obj_info        :=MI_Object_Info.Checked;
end; {$endregion}
{$endregion}

// {Custom Cursor} Кастомный курсор:
{LI} {$region -fold}
procedure CustomCursor(x,y:integer); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  F_MainForm.Cursor:=crNone;
  F_MainForm.Canvas.Draw(x-10,y-10,custom_icon);
end; {$endregion}
{$endregion}

// (Tray Icon) Системный трей:
{UI} {$region -fold}
procedure TF_MainForm.TrayIcon1Click(sender:TObject); {$region -fold}
begin
  F_MainForm.ShowOnTop;
end; {$endregion}
{$endregion}

// (Open) Импорт файла:
{UI} {$region -fold}
procedure TF_MainForm.MI_OpenClick(sender:TObject); {$region -fold}
var
  node_first: TTreeNode;
  execution_time: double;
  fcs_cnt,    {количество UV-островов, символов 'f' в импортируемом файле}
  eds_cnt,    {количество ребер, символов '/' в импортируемом файле}
  vts_cnt,    {количество вершин, символов 'v' в импортируемом файле}
  tex_vts_cnt,{количество текстурных вершин, строк 'vt' в импортируемом файле}
  i,j,k,m1,m2,m3,m4: integer;
  file_import: text;
  file_path,file_line,s: string;
begin
  begin
    k                       :=-1;
    fcs_cnt                 :=0;
    vts_cnt                 :=0;
    tex_vts_cnt             :=0;
    PB_ProgressBar1.Position:=0;
    SetLength(uv_var.uv_pts,1000000);
  end;
  OpenDialog1.Options:=OpenDialog1.Options+[ofFileMustExist];
  if (not OpenDialog1.Execute) then
    Exit;
  file_path:=OpenDialog1.Filename;
  Text:='MorphoEngine'+'('+file_path+')';
  exec_timer:=TPerformanceTime.Create;
  exec_timer.Start;
  AssignFile(file_import,file_path);
  Reset(file_import);

  while (not EOF(file_import)) do
    begin
      readln(file_import,file_line);
      for i:=0 to length(file_line)-1 do
        case file_line[i+1] of
          #32:
            case file_line[i] of
              'v': Inc(vts_cnt);
              'f': Inc(fcs_cnt);
            end;
          't':
            begin
              Inc(k);
              Inc(tex_vts_cnt);
              if file_line[i]='v' then
                begin
                  j:=i+2;
                  s:='';
                  while (not (file_line[j+1]=#32)) do
                    begin
                      Inc(j);
                      if file_line[j]='-' then
                        file_line[j]:='0';
                      if file_line[j]='.' then
                        file_line[j]:=',';
                      s:=s+file_line[j];
                      uv_var.uv_pts[k].x:=StrToFloat(s);
                    end;
                  Inc(j);
                  s:='';
                  while (not (file_line[j+1]=#32)) do
                    begin
                      Inc(j);
                      if file_line[j]='-' then
                        file_line[j]:='0';
                      if file_line[j]='.' then
                        file_line[j]:=',';
                      s:=s+file_line[j];
                      uv_var.uv_pts[k].y:=StrToFloat(s);
                    end;
                end;
            end;
        end;
    end;

  Repaint;
  with srf_var.srf_bmp.Canvas,srf_var,tex_var,uv_var do
    begin
      m1:=Trunc(tex_bmp_rct_pts[0].x)-2;
      m2:=Trunc(tex_bmp_rct_pts[0].y)-2;
      m3:=Trunc(tex_bmp_rct_pts[0].x)+3;
      m4:=Trunc(tex_bmp_rct_pts[0].y)+3;
      Pen.Color:=clBlack;
      Brush.Style:=bsClear;
      for i:=2 to tex_vts_cnt-1 do
        Rectangle(Trunc((tex_bmp_rct_pts[1].x-tex_bmp_rct_pts[0].x)*   uv_pts[i].x) +m1,
                  Trunc((tex_bmp_rct_pts[1].y-tex_bmp_rct_pts[0].y)*(1-uv_pts[i].y))+m2,
                  Trunc((tex_bmp_rct_pts[1].x-tex_bmp_rct_pts[0].x)*   uv_pts[i].x) +m3,
                  Trunc((tex_bmp_rct_pts[1].y-tex_bmp_rct_pts[0].y)*(1-uv_pts[i].y))+m4);
      Brush.Style:=bsSolid;
    end;
  InvalidateInnerWindow;

  eds_cnt:=vts_cnt; // TODO
  exec_timer.Stop;
  execution_time:=Trunc(exec_timer.Delay*1000)/1000;
  PB_ProgressBar1.Position:=100;
  L_Object_Info.Caption:=ObjectInfo0;
  node_first:=TV_Scene_Tree.Items.GetFirstVisibleNode;
  TV_Scene_Tree.Items.AddChild(node_first,ExtractFileName(OpenDialog1.Filename));
  node_first.Expanded:=true;
  {M_Loaded_File.Lines.LoadfromFile(OpenDialog1.Filename);}
  CloseFile(file_import);
end; {$endregion}
{$endregion}

// (Save as) Сохранение файла:
{UI} {$region -fold}
procedure TF_MainForm.MI_Save_AsClick(sender:TObject); {$region -fold}
begin
  SaveDialog1.Filter:='Wavefront Obj|*.obj|Text|*.txt|All files|*.*';
  if (not SaveDialog1.Execute) then
    Exit;
end; {$endregion}
{$endregion}

// (Exit) Выход из программы:
{UI} {$region -fold}
procedure TF_MainForm.MI_ExitClick(sender:TObject); {$region -fold}
begin
  Close;
end; {$endregion}
{$endregion}

// (3D Viewer) Трехмерный просмотр:
{UI} {$region -fold}
procedure TF_MainForm.MI_3D_ViewerClick(sender:TObject); {$region -fold}
begin
  {if MI_3D_Viewer.Checked then
    begin
      F_3D_Viewer.OpenGLControl1.Enabled  :=True;
      F_3D_Viewer.T_3DViewer_Timer.Enabled:=True;
      F_3D_Viewer.Show;
      F_3D_Viewer.BorderStyle:=TFormBorderStyle.bsNone;
      Align3DViewer;
    end
  else
    begin
      F_3D_Viewer.OpenGLControl1.Enabled  :=False;
      F_3D_Viewer.T_3DViewer_Timer.Enabled:=False;
      F_3D_Viewer.Hide;
    end;}
end; {$endregion}
{$endregion}

// (Full Screen) Полный экран:
{UI} {$region -fold}
procedure TF_MainForm.MI_Full_ScreenClick(sender:TObject); {$region -fold}
begin
  //S_Splitter1.Left:=269;
  S_Splitter4.Top :=176;
  case MI_Full_Screen.Checked of
    True :
      begin
        full_screen   :=True;
        BorderStyle   :=TFormBorderStyle.bsNone;
        S_Splitter0.Top :={491}P_UV_Operations.Top   +
                             P_UV_Operations.Height+20;
        S_Splitter2.Top :=558;
        S_Splitter3.Left:=835;
      end;
    False:
      begin
        full_screen   :=False;
        BorderStyle   :=bsSizeable;
        WindowState   :=wsFullScreen;
        CCB_2D_Operations_Automatic.Top:=250;
        S_Splitter0.Top :={491}P_UV_Operations.Top   +
                             P_UV_Operations.Height+20;
        S_Splitter2.Top :=536;
        S_Splitter3.Left:=835;
      end;
  end;
  srf_var.EventGroupsCalc(calc_arr,[0,1,2,3,4,6,8,9,16,17,18,20,21,22,28,30,31,32]);
end; {$endregion}
{$endregion}

// (Trancparency) Прозрачность:
{UI} {$region -fold}
procedure TF_MainForm.MI_TrancparencyClick(sender:TObject); {$region -fold}
begin

end; {$endregion}
{$endregion}

// (Hot Keys) Клавиатурная раскладка:
{UI} {$region -fold}
procedure TF_MainForm.MI_Hot_KeysClick(sender:TObject); {$region -fold}
begin
  if MI_Hot_Keys.Checked then
    F_Hot_Keys.Show
  else
    F_Hot_Keys.Hide;
end; {$endregion}
{$endregion}

// (SystemInfo) Системная информация:
{UI} {$region -fold}
procedure TF_MainForm.MI_System_InfoClick(sender:TObject); {$region -fold}
var
  size: longword;
  buffer: array[0..255] of char='';
  user_name,computer_name,info: string;
  {$ifdef Windows}
  flags: Windows.DWORD; // flags to pass to API function
  {$endif}
begin
  size:=256;
  {$ifdef Windows}
  flags:=0;
  GetUserName(buffer,size);
  user_name:=buffer;
  size:=MAX_COMPUTERNAME_LENGTH+1;
  GetComputerName(buffer,size);
  computer_name:=buffer;
  {$endif}
  info:='Date..................................' +{$i %DATE%}
   +#13+'System Bit........................'     +{$i %FPCTARGET%}
   +#13+'CPU...................................' +{$i %FPCTARGETCPU%}
   +#13+'CPU Count.......................'       +IntToStr(CPUCount)
   +#13+'OS.....................................'+{$i %FPCTARGETOS%}
   +#13+'FPC Version.....................'       +{$i %FPCVERSION%}
   {$ifdef Windows}
   +#13+'User Name......................'        +user_name
   +#13+'Computer Name............'              +computer_name
   {$endif}
   +#13+'Internet............................';
  {$ifdef Windows}
  if (WinInet.InternetGetConnectedState(@flags,0)) then
  {$else}
  if GetSystemMetrics(SM_NETWORK) and ($01=$01) then
  {$endif}
    info:=info+'Available'
  else
    info:=info+'Unavailable';
  MessageDlg(info,mtInformation,[mbOK],0);
end; {$endregion}
{$endregion}

// (Set Value, U)(Move) Установить значение по U:
{UI} {$region -fold}
procedure TF_MainForm.BB_Set_Value_UClick     (sender:TObject); {$region -fold}
begin
end; {$endregion}
procedure TF_MainForm.BB_Set_Value_UMouseLeave(sender:TObject); {$region -fold}

  procedure UnselectedPtsCalc2(var pts:array of TPtPosF); {$region -fold}
  var
    i: integer;
  begin
    with sel_var do
      for i:=0 to sel_pts_cnt-1 do
        pts[sel_pts_inds[i]].x:=pts[sel_pts_inds[i]].x+(pvt_var.pvt.x-pvt_var.pvt_origin.x)*FSE_Coord_U.Value*10;
  end; {$endregion}

begin
  if (sel_var.sel_pts_cnt>0) then
    UnselectedPtsCalc2(sln_var.sln_pts);
  {main_canvas_var.MainBmpPrepareDraw;}
end; {$endregion}
{$endregion}

// (Reset Value, U)(Move) Восстановить значение по U:
{UI} {$region -fold}
procedure TF_MainForm.BB_Reset_Value_UClick(sender:TObject); {$region -fold}
begin
  FSE_Coord_U.Value:=0;
end; {$endregion}
{$endregion}

// (Set Value, V)(Move) Установить значение по V:
{UI} {$region -fold}
procedure TF_MainForm.BB_Set_Value_VClick(sender:TObject); {$region -fold}
var
  check_border_v,i: integer;
begin
  with sln_var,sel_var do
    for i:=0 to sel_pts_cnt-1 do
      begin
        check_border_v:=Trunc(sln_pts[sel_pts_inds[i]].y-F_MainForm.Height*FSE_Coord_V.Value);
        if ((check_border_v>0) and (check_border_v<F_MainForm.Height)) then
          sln_pts[sel_pts_inds[i]].y:=check_border_v
        else
        if (check_border_v<0) then
          sln_pts[sel_pts_inds[i]].x:=0
        else
        if (check_border_v>F_MainForm.Width) then
          sln_pts[sel_pts_inds[i]].x:=F_MainForm.Width-1;
      end;
  InvalidateInnerWindow;
end; {$endregion}
{$endregion}

// (Reset Value, V)(Move) Восстановить значение по V:
{UI} {$region -fold}
procedure TF_MainForm.BB_Reset_Value_VClick(sender:TObject); {$region -fold}
begin
  FSE_Coord_V.value:=0;
end; {$endregion}
{$endregion}

// (Set All Values) Установить все значения:
{UI} {$region -fold}
procedure TF_MainForm.BB_Set_All_ValuesClick(sender:TObject); {$region -fold}
begin
  BB_Set_Value_UClick(FSE_Coord_U);
  BB_Set_Value_VClick(FSE_Coord_V);
end; {$endregion}
{$endregion}

// (Reset All Values) Восстановить все значения:
{UI} {$region -fold}
procedure TF_MainForm.BB_Reset_All_ValuesClick(sender:TObject); {$region -fold}
var
  i: integer;
begin
  for i:=0 to ComponentCount-1 do
    if (Components[i] is TFloatSpinEdit) then
      if byte(Components[i].tag) in [4,9,16,25,36] then
        TFloatSpinEdit(Components[i]).value:=0;
  FSE_Width.value :=1;
  FSE_Height.value:=1;
end; {$endregion}
{$endregion}

// (Move Pivot To Point) Переместить локальную ось в точку:
{UI} {$region -fold}
procedure TF_MainForm.SB_Move_Pivot_To_PointClick(sender:TObject); {$region -fold}
begin
  BtnColAndDown(SB_Move_Pivot_To_Point,pvt_var.move_pvt_to_pt_button);
end; {$endregion}
{$endregion}

// (Reset Pivot) Восстановить локальную ось:
{UI} {$region -fold}
procedure TF_MainForm.BB_Reset_PivotClick(sender:TObject); {$region -fold}
begin
  with sln_var,sel_var do
    if (sel_pts_cnt>0) then
      begin
        pvt_var.PivotCalc(sln_pts,sel_pts_inds,sel_pts_cnt);
        InvalidateInnerWindow;
      end;
end; {$endregion}
{$endregion}

// (Save UV) Сохранить актуальную развертку:
{LI} {$region -fold}
procedure TSavedUpPts.SavePts(const target_pts_arr:TPtPosFArr; const target_pts_cnt:TColor; var saved_up_pts_arr:TPtPosFArr; var saved_up_pts_arr_cnt:TColor); {$ifdef Linux}[local];{$endif} {$region -fold}
var
  saved_up_pts_arr_ptr:^TPtPosF;
  target_pts_arr_ptr  :^TPtPosF;
  i                   : integer;
begin
  saved_up_pts_arr:=Nil;
  SetLength(saved_up_pts_arr,target_pts_cnt);
  saved_up_pts_arr_ptr:=@saved_up_pts_arr[0];
  target_pts_arr_ptr  :=@target_pts_arr  [0];
  for i:=0 to target_pts_cnt-1 do
    begin
      saved_up_pts_arr_ptr^:=target_pts_arr_ptr^;
      Inc(saved_up_pts_arr_ptr);
      Inc(target_pts_arr_ptr);
    end;
  saved_up_pts_arr_cnt:=target_pts_cnt;
end; {$endregion}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.BB_Save_UVClick(sender:TObject);                                                                                                                                                {$region -fold}
begin
  with sln_var do
    sln_saved_up_pts_var.SavePts(sln_pts,
                                 sln_pts_cnt,
                                 sln_saved_up_pts_var.saved_up_pts,
                                 sln_saved_up_pts_var.saved_up_pts_cnt);
end; {$endregion}
{$endregion}

// (Reset UV) Вернуть сохраненную развертку:
{LI} {$region -fold}
procedure TSavedUpPts.ResetPts(var target_pts_arr:TPtPosFArr; const saved_up_pts_arr:TPtPosFArr; const saved_up_pts_arr_cnt:TColor; proc_ptr:TProc0); {$ifdef Linux}[local];{$endif} {$region -fold}
var
  saved_up_pts_arr_ptr:^TPtPosF;
  target_pts_arr_ptr  :^TPtPosF;
  i                   : integer;
begin
  saved_up_pts_arr_ptr:=@saved_up_pts_arr[0];
  target_pts_arr_ptr  :=@target_pts_arr  [0];
  for i:=0 to saved_up_pts_arr_cnt-1 do
    begin
      if (saved_up_pts_arr_ptr^.x<>0) and
         (saved_up_pts_arr_ptr^.y<>0) then
        target_pts_arr_ptr^:=saved_up_pts_arr_ptr^;
      Inc(saved_up_pts_arr_ptr);
      Inc(target_pts_arr_ptr);
    end;
  proc_ptr;
end; {$endregion}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.BB_Reset_UVClick(Sender:TObject);                                                                                                                                   {$region -fold}
begin
  with sln_var do
    sln_saved_up_pts_var.ResetPts(sln_pts,
                                  sln_saved_up_pts_var.saved_up_pts,
                                  sln_saved_up_pts_var.saved_up_pts_cnt,
                                  @srf_var.MainDraw);
end; {$endregion}
{$endregion}

// (2D Operations Attributes) Атрибуты 2D операций:
{UI} {$region -fold}
procedure TF_MainForm.CCB_2D_Operations_AutomaticItemChange(sender:TObject; AIndex:integer); {$region -fold}
begin
  sgr_var.align_pts:=F_MainForm.CCB_2D_Operations_Automatic.State[0]=cbChecked;
  srf_var.EventGroupsCalc(calc_arr,[18,30,31,32]);
end; {$endregion}
procedure TF_MainForm.CCB_2D_Operations_AutomaticGetItems  (sender:TObject);                 {$region -fold}
begin
  if CCB_2D_Operations_Automatic.ItemIndex=CCB_2D_Operations_Automatic.Items.Count-1 then
    case CCB_2D_Operations_Automatic.State[CCB_2D_Operations_Automatic.Items.Count-1] of
      cbChecked:
        CCB_2D_Operations_Automatic.CheckAll(cbChecked);
      cbUnchecked:
        CCB_2D_Operations_Automatic.CheckAll(cbUnchecked);
    end;
  InvalidateInnerWindow;
end; {$endregion}
procedure TF_MainForm.CCB_2D_Operations_AutomaticSelect    (sender:TObject);                 {$region -fold}
begin
end; {$endregion}
{$endregion}

// (Unfold Image Window) Развернуть окно:
{LI} {$region -fold}
procedure SplittersPosCalc;                                                                inline; {$ifdef Linux}[local]{$endif} {$region -fold}
begin
  {if (F_MainForm.width<678) then
    F_MainForm.width :=678;}
  if (F_MainForm.S_Splitter1.left<5{0}) then
    F_MainForm.S_Splitter1.left :=0;
  if (F_MainForm.S_Splitter3.left>F_MainForm.width -splitter_thickness-3) then
    F_MainForm.S_Splitter3.left :=F_MainForm.width -splitter_thickness;
  if (F_MainForm.S_Splitter2.top >F_MainForm.height-splitter_thickness-F_MainForm.SB_StatusBar1.height-0{20}) then
    F_MainForm.S_Splitter2.top  :=F_MainForm.height-splitter_thickness-F_MainForm.SB_StatusBar1.height-0{20};
  splitters_arr[0]^:=F_MainForm.S_Splitter0.top;
  splitters_arr[1]^:=F_MainForm.S_Splitter1.left;
  splitters_arr[2]^:=F_MainForm.S_Splitter2.top;
  splitters_arr[3]^:=F_MainForm.S_Splitter3.left;
  splitters_arr[4]^:=F_MainForm.S_Splitter4.top;
  splitters_arr[5]^:=F_MainForm.P_Splitter5.top;
  splitters_arr[6]^:=F_MainForm.S_Splitter6.top;
  splitters_arr[7]^:=F_MainForm.S_Splitter7.top;
end; {$endregion}
procedure IsControlEnbVis(control:TControl; _enabled:boolean=True; _visible:boolean=True); inline; {$ifdef Linux}[local]{$endif} {$region -fold}
begin
  control.Enabled:=_enabled;
  control.Visible:=_visible;
end; {$endregion}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.SB_Unfold_Image_WindowClick     (sender:TObject);                                                          {$region -fold}

  procedure UnfoldWindow; {$ifdef Linux}[local]{$endif} {$region -fold}

    procedure SetSplittersAnchors(space:TSpacingSize; control:TControl); {$ifdef Linux}[local]{$endif} {$region -fold}
    begin
      S_Splitter1         .AnchorParallel(akBottom,space,F_MainForm);
      S_Splitter3         .AnchorParallel(akBottom,space,F_MainForm);
      P_Image_Editor      .AnchorParallel(akBottom,space,F_MainForm);
      P_UV_Packing        .AnchorParallel(akBottom,space,F_MainForm);
      //S_TreeView_Splitter .AnchorParallel(akBottom,space,F_MainForm);
      //TV_Scene_Tree       .AnchorParallel(akBottom,space,F_MainForm);
      //SB_TreeView_Object_Tags.AnchorParallel(akBottom,space,F_MainForm);
    end; {$endregion}

  begin
    with F_MainForm do
      begin
        case tag of
          0:
            begin
              SetSplittersAnchors(0,F_MainForm);
              IsControlEnbVis(BB_Bottom_Splitter_To_Left ,False,False);
              IsControlEnbVis(BB_Bottom_Splitter_To_Right,False,False);
              IsControlEnbVis(PB_ProgressBar1            ,False,False);
              IsControlEnbVis(SB_StatusBar1              ,False,False);
              SB_StatusBar1.height    :=0;
              S_Splitter1  .left      :=0;
              S_Splitter2  .top       :=F_MainForm.height-splitter_thickness;
              S_Splitter3  .left      :=F_MainForm.width;
              S_TreeView_Splitter.left:=F_MainForm.width;
              tag:=1;
            end;
          1:
            begin
              //IsControlEnbVis(PB_ProgressBar1);
              //IsControlEnbVis(SB_StatusBar1  );
              //S_Splitter1.left:=269;
              SetSplittersAnchors(0,F_MainForm{SB_StatusBar1.height,SB_StatusBar1});
              //BB_Bottom_Splitter_To_Left .enabled:=True;
              //BB_Bottom_Splitter_To_Right.enabled:=True;
              //BB_Bottom_Splitter_To_Left .visible:=True;
              //BB_Bottom_Splitter_To_Right.visible:=True;
              S_Splitter2.top         :=F_MainForm.height-67;
              S_Splitter3.left        :=F_MainForm.width-200;
              S_TreeView_Splitter.left:=F_MainForm.width-50;
              tag:=0;
            end;
        end;
        SplittersPosCalc;
        SB_Unfold_Image_Window.down:=False;
      end;
  end; {$endregion}

begin
  UnfoldWindow;
  MoveBorders;
end; {$endregion}
procedure TF_MainForm.SB_Unfold_Image_WindowMouseLeave(sender:TObject);                                                          {$region -fold}
begin
  SB_Unfold_Image_Window.Repaint;
end; {$endregion}
{$endregion}

// (Original Image Size and Image Position) Исходный размер  и позиция изображения:
{UI} {$region -fold}
procedure TF_MainForm.MI_Align_Image_On_Inner_Window_ResizeClick(sender:TObject); {$region -fold}
begin
  align_picture_to_center:=MI_Align_Image_On_Inner_Window_Resize.Checked;
end; {$endregion}
procedure TF_MainForm.SB_Original_Texture_SizeClick             (sender:TObject); {$region -fold}
begin
  tex_var.AlignPictureToCenter;
  with srf_var,inn_wnd_rct do
    begin
      world_axis_shift:=PtPos((left+right )>>1-world_axis.x,
                              (top +bottom)>>1-world_axis.y);
      obj_var.SetWorldAxisShift(world_axis_shift);
      EventGroupsCalc(calc_arr,[8,9,18,30,31,32]);
      SpeedButtonRepaint;
      SB_Original_Texture_Size.down:=False;
    end;
end; {$endregion}
procedure TF_MainForm.SB_Original_Texture_SizeMouseLeave        (sender:TObject); {$region -fold}
begin
  SB_Original_Texture_Size.Repaint;
end; {$endregion}
{$endregion}

// (Align Image and 3D Viewer) Выравнивание изображения и 3D просмотра:
{LI} {$region -fold}
procedure Align3DViewer;         inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  monitor_width : TScreen;
  monitor_height: TScreen;
begin
  {if F_3D_Viewer.BorderStyle=TFormBorderStyle.bsNone then
    begin
      F_3D_Viewer.SetBounds(splitters_arr[3]^+splitter_thickness+1,43,
                            F_MainForm.S_Splitter4.width,
                     Trunc((F_MainForm.S_Splitter4.width*196)/186));
      F_3D_Viewer.Constraints.MaxHeight:=splitters_arr[4]^-2;
    end
  else if F_3D_Viewer.BorderStyle=bsSizeable then
    begin
      monitor_width :=TScreen.Create(F_MainForm);
      monitor_height:=TScreen.Create(F_MainForm);
      F_3D_Viewer.Constraints.MaxWidth :=monitor_width .DesktopWidth ;
      F_3D_Viewer.Constraints.MaxHeight:=monitor_height.DesktopHeight;
    end;}
end; {$endregion}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.S_Splitter0ChangeBounds         (sender:TObject); {$region -fold}
begin
  {$ifdef Windows}
  Application.ProcessMessages;
  {$else}
  SB_2D_Operations.Update;
  {$endif}
end; {$endregion}
procedure TF_MainForm.S_Splitter2ChangeBounds         (sender:TObject); {$region -fold}
var
  n: integer;

  procedure CheckBounds(exp1_,exp2_:boolean; k,m:integer); {$region -fold}
  begin
    if exp1_ and exp2_ then
      begin
        CCB_2D_Operations_Automatic.top:=k;
        S_Splitter0                .top:=n-22*m;
      end;
  end; {$endregion}

begin
  n:=P_UV_Operations.top
    +P_UV_Operations.height
    +CCB_2D_Operations_Automatic.height
    +P_UV_Attributes.height
    {+3*Trunc(CB_Align_2D_Points_Snap_Grid_Visibility.height/3)};
  case F_MainForm.Tag of
    {0:
      if (S_Splitter2.top+splitter_thickness>SB_StatusBar1.top) then
          S_Splitter2.top:=SB_StatusBar1.top-splitter_thickness;}
    1:
      if (S_Splitter2.top+splitter_thickness>F_MainForm.height) then
        S_Splitter2.top:=F_MainForm.height-splitter_thickness;
  end;
  {if (S_Splitter2.top< TV_Scene_Tree.top+P_Scene_Tree.height+7) then
       S_Splitter2.top:=TV_Scene_Tree.top+P_Scene_Tree.height+7;}
  CheckBounds((splitters_arr[1]^>=270),(splitters_arr[1]^<352),228,0);
  CheckBounds((splitters_arr[1]^>=352),(splitters_arr[1]^<466),206,1);
  CheckBounds((splitters_arr[1]^>=466),(splitters_arr[1]^<663),184,2);
  CheckBounds((splitters_arr[1]^>=663),True                   ,162,3);
  {$ifdef Windows}
  Application.ProcessMessages;
  {$else}
  Update;
  {$endif}
end; {$endregion}
procedure TF_MainForm.S_Splitter3ChangeBounds         (sender:TObject); {$region -fold}
begin
  //Align3DViewer;
  {$ifdef Windows}
  Application.ProcessMessages;
  {$else}
  SB_2D_Operations.Update;
  {$endif}
  S_TreeView_Splitter.left:=S_Splitter3.left+treeview_splitter_shift;
  if (S_TreeView_Splitter.left>F_MainForm.width-splitter_thickness) then
    S_TreeView_Splitter.left :=F_MainForm.width-splitter_thickness;
end; {$endregion}
procedure TF_MainForm.S_Splitter6ChangeBounds         (sender:TObject); {$region -fold}
begin
  TV_Scene_Tree.Update;
  SB_TreeView_Object_Tags.Update;
  SB_Object_Properties.Update;
end; {$endregion}
procedure TF_MainForm.S_Splitter7ChangeBounds         (sender:TObject); {$region -fold}
begin
  SB_Object_Properties.Update;
  SB_Tag_Properties.Update;
end; {$endregion}
procedure MoveBorders;           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  SplittersPosCalc;
  {TODO}
  F_MainForm.S_Splitter1.Left:=0;

  with srf_var,sel_var,crc_sel_var do
    begin
      EventGroupsCalc(calc_arr,[0,1,2,3,4,6,8,9,16,17,18,20,21,22,28,30,31,32,37]);
      if down_select_points_ptr^ then
        begin
          ResizeCircleSelectionModeDraw;
          AddCircleSelection;
          CrtCircleSelection;
          with crc_sel_rct do
           {CircleSelectionModeDraw(left+width >>1,
                                    top +height>>1,
                                    srf_var);}
            FilSelPtsObj(left,top);
        end;
    end;
  SpeedButtonRepaint;
end; {$endregion}
procedure TF_MainForm.S_Splitter1Moved                (sender:TObject); {$region -fold}
begin
  MoveBorders;
end; {$endregion}
procedure TF_MainForm.S_Splitter2Moved                (sender:TObject); {$region -fold}
begin
  MoveBorders;
end; {$endregion}
procedure TF_MainForm.S_Splitter3Moved                (sender:TObject); {$region -fold}
begin
  MoveBorders;
  treeview_splitter_shift:=S_TreeView_Splitter.left-S_Splitter3.left;
end; {$endregion}
procedure TF_MainForm.BB_Bottom_Splitter_To_LeftClick (sender:TObject); {$region -fold}
begin
  if (S_Splitter0.Top<=S_Splitter2.Top) then
    begin
      bottom_splitter_to_left:=not bottom_splitter_to_left;
      if bottom_splitter_to_left then
        begin
          BB_Bottom_Splitter_To_Left.Caption:='>';
          S_Splitter2   .AnchorParallel(akLeft  ,0 ,F_MainForm );
          S_Splitter1   .AnchorParallel(akBottom,0 ,S_Splitter2);
          P_Image_Editor.AnchorParallel(akLeft  ,0 ,F_MainForm );
          P_UV_Packing  .AnchorParallel(akBottom,0{10},S_Splitter2);
        end
      else
        begin
          BB_Bottom_Splitter_To_Left.Caption:='<';
          S_Splitter2   .AnchorParallel(akLeft  ,0 ,S_Splitter1  );
          S_Splitter1   .AnchorParallel(akBottom,0{23},SB_StatusBar1);
          P_Image_Editor.AnchorParallel(akLeft  ,0{10},S_Splitter1  );
          P_UV_Packing  .AnchorParallel(akBottom,0{23},SB_StatusBar1);
        end;
    end;
  BB_Bottom_Splitter_To_Left.Repaint;
end; {$endregion}
procedure TF_MainForm.BB_Bottom_Splitter_To_RightClick(sender:TObject); {$region -fold}
begin
  if (S_Splitter4.Top<=S_Splitter2.top) then
    begin
      bottom_splitter_to_right:=not bottom_splitter_to_right;
      if bottom_splitter_to_right then
        begin
          BB_Bottom_Splitter_To_Right.Caption:='<';
          S_Splitter2   .AnchorParallel(akRight ,0 ,F_MainForm );
          S_Splitter3   .AnchorParallel(akBottom,0 ,S_Splitter2);
          P_Image_Editor.AnchorParallel(akRight ,0 ,F_MainForm );
          TV_Scene_Tree .AnchorParallel(akBottom,0{10},S_Splitter2);
        end
      else
        begin
          BB_Bottom_Splitter_To_Right.Caption:='>';
          S_Splitter2   .AnchorParallel(akRight ,0 ,S_Splitter3  );
          S_Splitter3   .AnchorParallel(akBottom,0{23},SB_StatusBar1);
          P_Image_Editor.AnchorParallel(akRight ,0{10},S_Splitter3  );
          TV_Scene_Tree .AnchorParallel(akBottom,0{23},SB_StatusBar1);
        end;
    end;
  BB_Bottom_Splitter_To_Right.Repaint;
end; {$endregion}
{$endregion}

// (Selection Bounds) Ограничивающий прямоугольник при выделении кнопок:
{LI} {$region -fold}
procedure SelectionBounds(custom_bitmap:Graphics.TBitmap; custom_rect:TPtRect; custom_color:TColor; custom_width:integer); {$region -fold}
begin
  with custom_bitmap.Canvas do
    begin
      Pen.Mode :=pmNotCopy{pmMergeNotPen}{pmNotMask};
      Pen.Width:=custom_width;
      Pen.Color:=$FFFFFF-custom_color;
      Brush.Style:=bsClear;
      {$ifdef Windows}
      Windows.Rectangle(custom_bitmap.Canvas.Handle,
                        custom_rect.Left,
                        custom_rect.Top,
                        custom_rect.Right,
                        custom_rect.Bottom);
      {$else}
      Rectangle(custom_rect.Left,
                custom_rect.Top,
                custom_rect.Right,
                custom_rect.Bottom);
      {$endif}
    end;
end; {$endregion}
procedure SelectionBoundsRepaint; inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  k: integer;
begin
  with F_MainForm do
    begin
      visibility_panel_picture.PixelFormat:=pf32bit;
      SelectionBounds(visibility_panel_picture,PtRct(2,2,I_Visibility_Panel.Width-1,I_Visibility_Panel.Height-1),$00CBDAB1,4);
      for k:=0 to 4{5} do
        SelectionBounds(visibility_panel_picture,PtRct(2,28+36*k,I_Visibility_Panel.Width-1,65+36*k),$00CBDAB1,2);
    end;
end; {$endregion}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.I_Visibility_PanelPaint          (sender:TObject); {$region -fold}
begin
  I_Visibility_Panel.Canvas.Draw(0,0,visibility_panel_picture);
end; {$endregion}
procedure TF_MainForm.I_Visibility_PanelMouseLeave     (sender:TObject); {$region -fold}
begin
  SelectionBoundsRepaint;
  I_Visibility_Panel.Repaint;
end; {$endregion}
procedure TF_MainForm.SB_Visibility_TextureMouseEnter  (sender:TObject); {$region -fold}
begin
  SelectionBoundsRepaint;
  SelectionBounds(visibility_panel_picture,PtRct(2,28,I_Visibility_Panel.Width-1,65),clBlue,2);
  I_Visibility_Panel.Invalidate;
end; {$endregion}
procedure TF_MainForm.SB_Visibility_GridMouseEnter     (sender:TObject); {$region -fold}
begin
  SelectionBoundsRepaint;
  SelectionBounds(visibility_panel_picture,PtRct(2,64,I_Visibility_Panel.Width-1,101),clBlue,2);
  I_Visibility_Panel.Invalidate;
end; {$endregion}
procedure TF_MainForm.SB_Visibility_Snap_GridMouseEnter(sender:TObject); {$region -fold}
begin
  SelectionBoundsRepaint;
  SelectionBounds(visibility_panel_picture,PtRct(2,100,I_Visibility_Panel.Width-1,137),clBlue,2);
  I_Visibility_Panel.Invalidate;
end; {$endregion}
procedure TF_MainForm.SB_Visibility_SplineMouseEnter   (sender:TObject); {$region -fold}
begin
  SelectionBoundsRepaint;
  SelectionBounds(visibility_panel_picture,PtRct(2,136,I_Visibility_Panel.Width-1,173),clBlue,2);
  I_Visibility_Panel.Invalidate;
end; {$endregion}
procedure TF_MainForm.SB_Visibility_ActorMouseEnter  (sender:TObject); {$region -fold}
begin
  SelectionBoundsRepaint;
  SelectionBounds(visibility_panel_picture,PtRct(2,172,I_Visibility_Panel.Width-1,209),clBlue,2);
  I_Visibility_Panel.Invalidate;
end; {$endregion}
procedure TF_MainForm.SB_Visibility_ColliderMouseEnter (sender:TObject); {$region -fold}
begin
  SelectionBoundsRepaint;
  SelectionBounds(visibility_panel_picture,PtRct(2,208,I_Visibility_Panel.Width-1,245),clBlue,2);
  I_Visibility_Panel.Invalidate;
end; {$endregion}
{$endregion}

// (Visibility Panel) Панель видимости:
{LI} {$region -fold}
procedure TF_MainForm.VisibilityChange(set_visibility:boolean); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  I_Visibility_Panel      .Visible:=set_visibility;
  SB_Unfold_Image_Window  .Visible:=set_visibility;
  SB_Original_Texture_Size.Visible:=set_visibility;
  SB_Visibility_Texture   .Visible:=set_visibility;
  SB_Visibility_Grid      .Visible:=set_visibility;
  SB_Visibility_Spline    .Visible:=set_visibility;
  SB_Visibility_Collider  .Visible:=set_visibility;
  SB_Visibility_Actor   .Visible:=set_visibility;
  SB_Visibility_Snap_Grid .Visible:=set_visibility;
  SB_Visibility_Show_All  .Visible:=set_visibility;
  L_Object_Info           .Visible:=set_visibility;
  L_Exec_Time_Info        .Visible:=set_visibility;
  L_Speed                 .Visible:=set_visibility;
  TB_Speed                .Visible:=set_visibility;
  MI_Object_Info          .Checked:=set_visibility;
  show_obj_info                   :=set_visibility;
  show_tex_info                   :=set_visibility;
end; {$endregion}
procedure SetVisibility(btn:TSpeedButton; var &exp:boolean);    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  btn.Transparent:=&exp;
  &exp       :=not &exp;
  btn.Down:=False;
  srf_var.EventGroupsCalc(calc_arr,[30]);
end; {$endregion}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.SB_Visibility_TextureClick  (sender:TObject);                                    {$region -fold}
begin
  SetVisibility(SB_Visibility_Texture,show_tex);
  SpeedButtonRepaint;
  srf_var.low_bmp_draw:=show_grid or show_snap_grid or (show_spline and (sln_var.sln_pts_cnt<>0));
end; {$endregion}
procedure TF_MainForm.SB_Visibility_GridClick     (sender:TObject);                                    {$region -fold}
begin
  SetVisibility(SB_Visibility_Grid,show_grid);
  SpeedButtonRepaint;
  srf_var.low_bmp_draw:=show_grid or show_snap_grid or (show_spline and (sln_var.sln_pts_cnt<>0));
end; {$endregion}
procedure TF_MainForm.SB_Visibility_Snap_GridClick(sender:TObject);                                    {$region -fold}
begin
  SetVisibility(SB_Visibility_Snap_Grid,show_snap_grid);
  SpeedButtonRepaint;
  srf_var.low_bmp_draw:=show_grid or show_snap_grid or (show_spline and (sln_var.sln_pts_cnt<>0));
end; {$endregion}
procedure TF_MainForm.SB_Visibility_SplineClick   (sender:TObject);                                    {$region -fold}
begin
  repaint_spline_calc:=True;
  rectangles_calc    :=True;
  spline_scale_calc  :=True;
  srf_var.scl_dir    :=sdNone;
  SetVisibility(SB_Visibility_Spline,show_spline);
  repaint_spline_calc:=False;
  rectangles_calc    :=False;
  spline_scale_calc  :=False;
  SpeedButtonRepaint;
  srf_var.low_bmp_draw:=show_grid or show_snap_grid or (show_spline and (sln_var.sln_pts_cnt<>0));
end; {$endregion}
procedure TF_MainForm.SB_Visibility_ActorClick    (sender:TObject);                                    {$region -fold}
begin
  SetVisibility(SB_Visibility_Actor,show_actor);
  SpeedButtonRepaint;
  srf_var.low_bmp_draw:=show_grid or show_snap_grid or (show_spline and (sln_var.sln_pts_cnt<>0));
end; {$endregion}
procedure TF_MainForm.SB_Visibility_ColliderClick (sender:TObject);                                    {$region -fold}
begin
  SetVisibility(SB_Visibility_Collider,show_collider);
  SpeedButtonRepaint;
  srf_var.low_bmp_draw:=show_grid or show_snap_grid or (show_spline and (sln_var.sln_pts_cnt<>0));
end; {$endregion}
procedure TF_MainForm.SB_Visibility_Show_AllClick (sender:TObject);                                    {$region -fold}
var
  i: integer;
begin
  show_all                           :=not show_all;
  SB_Visibility_Texture  .Transparent:=not show_all;
  SB_Visibility_Grid     .Transparent:=not show_all;
  SB_Visibility_Snap_Grid.Transparent:=not show_all;
  SB_Visibility_Spline   .Transparent:=not show_all;
  SB_Visibility_Actor    .Transparent:=not show_all;
  SB_Visibility_Collider .Transparent:=not show_all;
  SB_Visibility_Show_All .Transparent:=not show_all;
  for i:=0 to High(show_obj_arr){-1} do
    show_obj_arr[i]:=show_all;
  SB_Visibility_Show_All.Down:=False;
  srf_var.scl_dir            :=sdNone;
  srf_var.EventGroupsCalc(calc_arr,[18,19,30,31,32]);
  SpeedButtonRepaint;
  srf_var.low_bmp_draw:=show_grid or show_snap_grid {or (show_spline and (sln_var.sln_pts_cnt<>0))};
end; {$endregion}
{$endregion}

// (Color Scheme) Выбор цвета обьектов "Grid","Spline",...:
{UI} {$region -fold}
procedure SetObjectColor(speed_button:TSpeedButton; var custom_color:TColor); {$region -fold}
begin
  F_MainForm.CD_Select_Color.Color:=speed_button.Color;
  F_MainForm.CD_Select_Color.Execute;
  speed_button.Color:=F_MainForm.CD_Select_Color.Color;
  custom_color      :=F_MainForm.CD_Select_Color.Color;
  srf_var.MainDraw;
  speed_button.Down:=False;
end; {$endregion}
procedure TF_MainForm.SB_Background_ColorClick(sender:TObject);               {$region -fold}
begin
end; {$endregion}
procedure TF_MainForm.SB_Grid_ColorClick      (sender:TObject);               {$region -fold}
begin
end; {$endregion}
procedure TF_MainForm.SB_Snap_Grid_ColorClick (sender:TObject);               {$region -fold}
begin
end; {$endregion}
procedure TF_MainForm.SB_Spline_ColorClick    (sender:TObject);               {$region -fold}
begin
end; {$endregion}
procedure TF_MainForm.SB_UV_Mesh_ColorClick   (sender:TObject);               {$region -fold}
begin
end; {$endregion}
procedure TF_MainForm.SB_IS_Graph_ColorClick  (sender:TObject);               {$region -fold}
begin
end; {$endregion}
{$endregion}

// (Clear Image) Очистить изображение:
{UI} {$region -fold}
procedure TF_MainForm.SB_Clear_SceneClick    (sender:TObject); {$region -fold}
begin
  P_Selective_Deletion.Visible:=SB_Clear_Scene.Down;
  P_Load_Save_Clear.Repaint;
end; {$endregion}
procedure TF_MainForm.BB_Delete_SelectedClick(sender:TObject); {$region -fold}
begin
end; {$endregion}
procedure TF_MainForm.BB_Delete_AllClick     (sender:TObject); {$region -fold}
var
  i: integer;
begin
  with srf_var,tex_var,sln_var,sel_var do
    begin

      {Clear Layer Canvas}
      srf_bmp.Canvas.Clear;
      low_bmp.Canvas.Clear;

      {Clear Texture List}
      for i:=FP_Image_List.ControlCount-1 downto 0 do
        FP_Image_List.Controls[i].Destroy;

      {Clear Scene Tree Nodes}
      with TV_Scene_Tree do
        begin
          Items[0].DeleteChildren;
          if Items.Count>1 then
            for i:=1 to Items.Count-1 do
              ClearNodeData(Items[i]);
        end;

      {Reset Layer Bounding Rectangles}
      srf_bmp_rct:=Default(TPtRect);

      {Clear And Allocate Arrays}
      MainArraysDone;
      //MainArraysInit(set_array_mem);

      {Reset Texture}
      is_tex_enabled :=False;
      loaded_picture.Clear;
      loaded_picture :=Graphics.TPicture.Create;
      tex_bmp_rct_pts:=tex_bmp_rct_origin_pts;

      {Reset Miscellaneous Parameters}
      SB_StatusBar1.Panels.Items[2].Text:='';
      L_Object_Info.Caption             :='';
      FP_Image_List.Caption             :='Texture List is Empty';
      L_Object_Info.Visible             :=False;
    //MI_Antialiasing.Checked           :=False;
    //srf_bmp.Canvas.Antialiasingmode   :=amOff;
      AlignPictureToCenter;
      EventGroupsCalc(calc_arr,[0,1,2,8,9]);

    end;
end; {$endregion}
{$endregion}

// (Buttons PopUp Menu) Всплывающее меню панели инструментов:
{UI} {$region -fold}
procedure ButtonsPopUpMenu(panel:TPanel; menu_item:TMenuItem; col1,col2,col3:TColor; &transparent:boolean); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if menu_item.Checked then
    begin
      panel.BevelColor:=col1;
      panel.Color     :=col2;
    end;
  for i:=0 to panel.ControlCount-1 do
    begin
      (panel.Controls[i] as TSpeedButton).Transparent:=&transparent;
      (panel.Controls[i] as TSpeedButton).Flat       :=&transparent;
       panel.Controls[i].Color:=col3;
    end;
end; {$endregion}
procedure TF_MainForm.MI_Button_Style_1Click(Sender:TObject); {$region -fold}
begin
  ButtonsPopUpMenu(P_Drawing_Buttons,MI_Button_Style_1,$00D2CE9D,$00F2F1E3,$009DD7E6,MI_Button_Style_1.Checked);
end; {$endregion}
procedure TF_MainForm.MI_Button_Style_2Click(Sender:TObject); {$region -fold}
begin
  ButtonsPopUpMenu(P_Drawing_Buttons,MI_Button_Style_2,$00ABAFA3,$00ABAFA3,$009DD7E6,not MI_Button_Style_2.Checked);
end; {$endregion}
{$endregion}

// (Buttons Colorize) Окраска кнопок при нажатии:
{LI} {$region -fold}
procedure BtnColAndDown    (constref spd_btn:TSpeedButton; var down_flag:boolean; color_down:TColor=NAV_SEL_COL_0; color_up:TColor=$00CBDAB1); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with spd_btn do
    begin
      Flat:=Down;
      if Down then
        Color:=color_down
      else
        Color:=color_up;
    end;
  down_flag:=not down_flag;
end; {$endregion}
procedure MouseMoveProcInit(pnl:TPanel; pnl_proc:TMouseMoveEvent);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  for i:=0 to pnl.ControlCount-1 do
    (pnl.Controls[i] as TSpeedButton).OnMouseMove:=pnl_proc;
end; {$endregion}
procedure ButtonColorize   (prnt_pnl:TPanel; btn_col:TColor=NAV_SEL_COL_0);                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  for i:=0 to prnt_pnl.ControlCount-1 do
    begin
     (prnt_pnl.Controls[i] as TSpeedButton).Transparent:=not (prnt_pnl.Controls[i] as TSpeedButton).Down;
      prnt_pnl.Controls[i].Color:=btn_col;
    end;
end; {$endregion}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.P_Load_Save_ClearPaint      (sender:TObject);                                 {$region -fold}
begin
  ButtonColorize(P_Load_Save_Clear);
end; {$endregion}
procedure TF_MainForm.P_Drawing_ButtonsPaint      (sender:TObject);                                 {$region -fold}
begin
  ButtonColorize(P_Drawing_Buttons);
end; {$endregion}
procedure TF_MainForm.P_Animation_ButtonsPaint    (sender:TObject);                                 {$region -fold}
begin
  ButtonColorize(P_Animation_Buttons);
end; {$endregion}
procedure TF_MainForm.P_Drawing_ButtonsMouseMove  (sender:TObject; shift:TShiftState; x,y:integer); {$region -fold}
begin
  P_Drawing_Buttons.Repaint;
end; {$endregion}
procedure TF_MainForm.P_Animation_ButtonsMouseMove(sender:TObject; shift:TShiftState; x,y:integer); {$region -fold}
begin
  P_Animation_Buttons.Repaint;
end; {$endregion}
{$endregion}

// (Buttons Scroll) Прокрутка панели кнопок:
{LI} {$region -fold}
procedure ButtonMoveToPrevPos(prnt_pnl:TPanel; constref btn:TControl; constref min_param,btn_width,margin:integer; constref left_or_top:TParamType); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  case left_or_top of
    ptLeft:
      begin
        if (btn.left=min_param) then
          Exit;
        for i in [0..prnt_pnl.ControlCount-1] do
          prnt_pnl.Controls[i].left:=prnt_pnl.Controls[i].left-(btn_width+margin);
      end;
    ptTop:
      begin
        if (btn.top=min_param) then
          Exit;
        for i in [0..prnt_pnl.ControlCount-1] do
          prnt_pnl.Controls[i].top:=prnt_pnl.Controls[i].top-(btn_width+margin);
      end;
  end;
end; {$endregion}
procedure ButtonMoveToSuccPos(prnt_pnl:TPanel; constref btn:TControl; constref max_param,btn_width,margin:integer; constref left_or_top:TParamType); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  case left_or_top of
    ptLeft:
      begin
        if (btn.left=max_param) then
          Exit;
        for i in [0..prnt_pnl.ControlCount-1] do
          prnt_pnl.Controls[i].left:=prnt_pnl.Controls[i].left+(btn_width+margin);
      end;
    ptTop:
      begin
        if (btn.top=max_param) then
          Exit;
        for i in [0..prnt_pnl.ControlCount-1] do
          prnt_pnl.Controls[i].top:=prnt_pnl.Controls[i].top+(btn_width+margin);
      end;
  end;
end; {$endregion}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.TS_DrawMouseWheelDown(sender:TObject; shift:TShiftState; mousepos:TPoint; var handled:boolean); {$region -fold}
begin
  //ButtonStripWheelDown(P_Drawing_Buttons,S_Splitter2.width,32);
end; {$endregion}
procedure TF_MainForm.TS_DrawMouseWheelUp  (sender:TObject; shift:TShiftState; mousepos:TPoint; var handled:boolean); {$region -fold}
begin
  //ButtonStripWheelUp(P_Drawing_Buttons,S_Splitter2.width,32);
end; {$endregion}
{$endregion}

// (Buttons Panels Visibility) Видимость панелей для инструментов рисования:
{LI} {$region -fold}
procedure DrawingPanelsSetVisibility1(var down_button_ptr:PByteBool; active_panel,empty_panel:TPanel; var prev_panel,curr_panel:TPanel); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  curr_panel:=active_panel;
  if (not down_button_ptr^) then
    begin
      prev_panel .visible:=False;
      empty_panel.visible:=True;
      curr_panel .visible:=False;
    end
  else
    begin
      prev_panel .visible:=False;
      empty_panel.visible:=False;
      curr_panel .visible:=True;
    end;
  prev_panel:=curr_panel;
end; {$endregion}
procedure DrawingPanelsSetVisibility2;                                                                                                   inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  if down_select_points_ptr^ then
    crc_sel_var.only_fill:=False;
  if sln_var.has_hid_ln_elim_sln then
    begin
      if (not down_select_points_ptr^) then
        begin
          if (not repaint_spline_hid_ln_calc1) and (down_spline_ptr^) then
            begin
              sln_var.rep_hid_ln_elim_first:=True;
              srf_var.EventGroupsCalc(calc_arr,[18,23,24,27,30,31,32,34]);
              repaint_spline_hid_ln_calc1:=True;
              repaint_spline_hid_ln_calc2:=False;
            end;
        end
      else
        begin
          if (not repaint_spline_hid_ln_calc2) then
            begin
              sln_var.rep_hid_ln_elim_first:=True;
              srf_var.EventGroupsCalc(calc_arr,[18,23,24,30,31,32]);
              repaint_spline_hid_ln_calc1:=False;
              repaint_spline_hid_ln_calc2:=True;
            end;
        end;
    end
  else
    if (not down_select_points_ptr^) and (sel_var.sel_pts_cnt<>0) then
      srf_var.EventGroupsCalc(calc_arr,[18,23,24,27,30,31,32]);
end; {$endregion}
{$endregion}

// (Main Layer) Основной слой:
{LI} {$region -fold}
constructor TSurf.Create(w,h:TColor);                                                                                                       {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  obj_var.Add(kooBkgnd,world_axis_shift);
  CreateNode('Background','');
  ObjIndsCalc;
  ScTIndsCalc;

  srf_bmp:=Graphics.TBitmap.Create;
  {$ifopt D+}
  srf_bmp.PixelFormat:=pfDevice;
  {$endif}

  test_bmp:=Graphics.TBitmap.Create;
  {$ifopt D+}
  test_bmp.PixelFormat:=pfDevice;
  {$endif}

  low_bmp:=Graphics.TBitmap.Create;
  {$ifopt D+}
  low_bmp.PixelFormat:=pfDevice;
  {$endif}
  low_bmp_draw:=True;

  low_bmp2:=Graphics.TBitmap.Create;
  {$ifopt D+}
  low_bmp2.PixelFormat:=pfDevice;
  {$endif}
  low_bmp2_draw:=False;

  parallax_shift            :=obj_default_prop.parallax_shift;
  show_all                  :=True;
  inner_window_ui_visible   :=True;
  bg_color                  :={clBlack}clDkGray{clLtGray};
  srf_bmp.Canvas.Brush.Color:=bg_color;

  SetTextInfo(srf_bmp.Canvas,32,$00E6F9EB,'AR DESTINE');
end; {$endregion}
destructor  TSurf.Destroy;                                                                                                                  {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  inherited Destroy;
end; {$endregion}
procedure InvalidateInnerWindow;                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  {$ifdef Windows}
  InvalidateRect(F_MainForm.Handle,
                 Rect(splitters_arr[1]^+splitter_thickness,
                      splitters_arr[5]^+splitter_thickness,
                      splitters_arr[3]^,
                      splitters_arr[2]^),
                 True);
  {$else}
  Invalidate;
  {$endif}
end; {$endregion}
procedure InvalidateRegion(rct_dst:TRect);                                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  {$ifdef Windows}
  InvalidateRect(F_MainForm.Handle,
                 Rect(rct_dst.Left,
                      rct_dst.Top,
                      rct_dst.Right,
                      rct_dst.Bottom),
                 True);
  {$else}
  Invalidate;
  {$endif}
end; {$endregion}
procedure TSurf.MainBmpRectCalc;                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  srf_bmp_rct:=PtBounds(0,0,{1024}F_MainForm.Width,{640}F_MainForm.Height);
  inn_wnd_rct:=PtRct({0000}splitters_arr[1]^+splitter_thickness+inn_wnd_mrg,
                     {0000}splitters_arr[5]^+splitter_thickness+inn_wnd_mrg,
                     {1022}splitters_arr[3]^                   -inn_wnd_mrg,
                     {0638}splitters_arr[2]^                   -inn_wnd_mrg);
  pvt_var.SetPivotAxisRect(inn_wnd_rct);
end; {$endregion}
procedure TSurf.MainBmpSizeCalc;                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  srf_bmp .width :=srf_bmp_rct.width ;
  srf_bmp .height:=srf_bmp_rct.height;
  test_bmp .width :=srf_bmp_rct.width ;
  test_bmp .height:=srf_bmp_rct.height;
  low_bmp .width :=srf_bmp_rct.width ;
  low_bmp .height:=srf_bmp_rct.height;
  low_bmp2.width :=srf_bmp_rct.width ;
  low_bmp2.height:=srf_bmp_rct.height;
  rot_arr_width  :=srf_bmp_rct.width ;
  rot_arr_height :=srf_bmp_rct.height;
  if show_tex then
    with tex_var do
      begin
        tex_bmp.width :=Trunc(tex_bmp_rct_pts[1].x-tex_bmp_rct_pts[0].x);
        tex_bmp.height:=Trunc(tex_bmp_rct_pts[1].y-tex_bmp_rct_pts[0].y);
      end;
end; {$endregion}
procedure TSurf.MainBmpArrsCalc;                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

  {Spline--------} {$region -fold}
  with sln_var do
    begin
      with rct_eds_big_img do
        begin
          SetBkgnd  (srf_bmp_ptr            ,srf_bmp.width,srf_bmp.height);
          SplineInit(                        srf_bmp.width,srf_bmp.height,False,True,False,False);
        end;
      with rct_pts_big_img do
        begin
          SetBkgnd  (srf_bmp_ptr            ,srf_bmp.width,srf_bmp.height);
          SplineInit(                        srf_bmp.width,srf_bmp.height,False,True,False,False);
        end;
      with eds_big_img do
        begin
          SetBkgnd  (srf_bmp_ptr            ,srf_bmp.width,srf_bmp.height);
          SplineInit(                        srf_bmp.width,srf_bmp.height,True,True,False,True);
        end;
      with pts_big_img do
        begin
          SetBkgnd  (srf_bmp_ptr            ,srf_bmp.width,srf_bmp.height);
          SplineInit(                        srf_bmp.width,srf_bmp.height,True,True,False,True);
        end;

      //dup_pts_arr            :=Nil;
      SetLength     (dup_pts_arr            ,srf_bmp.width*srf_bmp.height);
      ArrClear      (dup_pts_arr            ,inn_wnd_rct,  srf_bmp.width );

      {
      //rct_eds_useless_fld_arr:=Nil;
      SetLength     (rct_eds_useless_fld_arr,srf_bmp.width*srf_bmp.height);
      ArrClear      (rct_eds_useless_fld_arr,inn_wnd_rct,  srf_bmp.width );

      //rct_pts_useless_fld_arr:=Nil;
      SetLength     (rct_pts_useless_fld_arr,srf_bmp.width*srf_bmp.height);
      ArrClear      (rct_pts_useless_fld_arr,inn_wnd_rct,  srf_bmp.width );
      }

      //    eds_useless_fld_arr:=Nil;
      SetLength     (    eds_useless_fld_arr,srf_bmp.width*srf_bmp.height);
      ArrClear      (    eds_useless_fld_arr,inn_wnd_rct,  srf_bmp.width );

      {
      //    pts_useless_fld_arr:=Nil;
      SetLength     (    pts_useless_fld_arr,srf_bmp.width*srf_bmp.height);
      ArrClear      (    pts_useless_fld_arr,inn_wnd_rct,  srf_bmp.width );
      }

    end; {$endregion}

  {Selected Edges} {$region -fold}
  with sel_var do
    begin
      with outer_subgraph_img do
        begin
          SetBkgnd  (srf_bmp_ptr,srf_bmp.width,srf_bmp.height);
          SplineInit(            srf_bmp.width,srf_bmp.height,True,True,True,True);
          GCCArrInit;
        end;
      with inner_subgraph_img do
        begin
          SetBkgnd  (srf_bmp_ptr,srf_bmp.width,srf_bmp.height);
          SplineInit(            srf_bmp.width,srf_bmp.height,True,True,True,True);
          GCCArrRepl(outer_subgraph_img); // GCCArrInit;
        end;
      with sel_pts_big_img do
        begin
          SetBkgnd  (srf_bmp_ptr,srf_bmp.width,srf_bmp.height);
          SplineInit(            srf_bmp.width,srf_bmp.height,True,True,True,True);
        end;
    end; {$endregion}

  {Physics-------} {$region -fold}
  SetLength(fast_physics_var.coll_box_arr,srf_bmp.width*srf_bmp.height);
  SetLength(coll_arr                     ,srf_bmp.width*srf_bmp.height);
  SetLength(projectile_arr,10000); {$endregion}

  {Baking Sprites} {$region -fold}
  SetLength(rot_arr            ,srf_bmp.width*srf_bmp.height);
  ArrClear (rot_arr,inn_wnd_rct,srf_bmp.width);
  rot_arr_ptr:=Unaligned(@rot_arr[0]); {$endregion}

end; {$endregion}
procedure TSurf.InnerWindowDraw(color:TColor);                                                                                      inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rct_prop: TCurveProp;
  a,b     : integer;
begin
  {with dst_canvas do
    begin
     a:=Trunc((inn_wnd_mrg+1)/2);
      b:=inn_wnd_mrg;
      if Odd(b) then
        b:=a
      else
        b:=a+1;
      Brush.Style:=bsClear;
      Pen.Mode   :=pmCopy;
      Pen.Color  :=color;
      Pen.Width  :=inn_wnd_mrg;
      Rectangle(srf_var.inn_wnd_rct.left  -a,
                srf_var.inn_wnd_rct.top   -a,
                srf_var.inn_wnd_rct.right +b,
                srf_var.inn_wnd_rct.bottom+b);
      Pen.Width:=1;
    end;}
  with rct_prop do
    begin
      pts_col           :=color;
      pts_col_inv       :=SetColorInv(color);
      pts_rct_tns_left  :=inn_wnd_mrg;
      pts_rct_tns_top   :=inn_wnd_mrg;
      pts_rct_tns_right :=inn_wnd_mrg;
      pts_rct_tns_bottom:=inn_wnd_mrg;
      pts_rct_inn_width :=inn_wnd_rct.width ;
      pts_rct_inn_height:=inn_wnd_rct.height;
      SetRctWidth (rct_prop);
      SetRctHeight(rct_prop);
      SetRctValues(rct_prop);
      Fast_Primitives.Rectangle
      (
        inn_wnd_rct.left+inn_wnd_rct.width >>1-pts_rct_width__odd,
        inn_wnd_rct.top +inn_wnd_rct.height>>1-pts_rct_height_odd,
        srf_bmp_ptr,
        srf_bmp.width,
        srf_bmp.height,
        PtBounds
        (
          inn_wnd_rct.left  -inn_wnd_mrg,
          inn_wnd_rct.top   -inn_wnd_mrg,
          inn_wnd_rct.right +inn_wnd_mrg,
          inn_wnd_rct.bottom+inn_wnd_mrg
        ),
        rct_prop
      );
    end;
end; {$endregion}
procedure TSurf.BmpSettings(bmp_dst:Graphics.TBitmap; pen_color:TColor; pen_mode:TPenMode=pmCopy; brush_style:TBrushStyle=bsSolid); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with bmp_dst.Canvas do
    begin
      Pen.Mode   :=pen_mode{pmNotCopy}{pmMergeNotPen}{pmNotMask};
      Pen.Color  :=(*//$FFFFFF-*)pen_color;
      Brush.Style:=brush_style;
    end;
end; {$endregion}
procedure TSurf.MainBmpToLowerBmp;                                                                                                  inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  BmpToBmp2(srf_bmp_ptr,low_bmp_ptr,srf_bmp.width,low_bmp.width,inn_wnd_rct,inn_wnd_mrg);
end; {$endregion}
procedure TSurf.MainBmpToLowerBmp2;                                                                                                 inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  BmpToBmp2(srf_bmp_ptr,low_bmp2_ptr,srf_bmp.width,low_bmp2.width,inn_wnd_rct,inn_wnd_mrg);
end; {$endregion}
procedure TSurf.LowerBmpToMainBmp;                                                                                                  inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  BmpToBmp2(low_bmp_ptr,srf_bmp_ptr,low_bmp.width,srf_bmp.width,inn_wnd_rct,inn_wnd_mrg);
end; {$endregion}
procedure TSurf.LowerBmp2ToMainBmp;                                                                                                 inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  BmpToBmp2(low_bmp2_ptr,srf_bmp_ptr,low_bmp2.width,srf_bmp.width,inn_wnd_rct,inn_wnd_mrg);
end; {$endregion}
procedure TSurf.FilBkgndObj(constref bkgnd_ind:TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with obj_var.obj_arr[obj_var.bkgnd_inds_obj_arr[bkgnd_ind]] do
    PPFloodFill(bkgnd_ptr,rct_clp,bkgnd_width,bg_color);
end; {$endregion}
procedure TSurf.SetBkgnd(constref bkgnd_ptr:PInteger; constref bkgnd_width,bkgnd_height:TColor; constref rct_clp:TPtRect);          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
  i          : integer;
begin
  with obj_var do
    if (obj_var<>Nil) and (obj_cnt>0)  then
      begin
        obj_arr_ptr:=Unaligned(@obj_arr[0]);
        Prefetch(obj_arr_ptr);
        for i:=0 to obj_cnt-1 do
          SetObjBkgnd
          (
            @(obj_arr_ptr+i)^,
            bkgnd_ptr,
            bkgnd_width,
            bkgnd_height,
            rct_clp
          );
      end;
end; {$endregion}
{Events Queue}
{Get Handles---------------------------------}
procedure TSurf.GetHandles;                                                                                                         inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with obj_var,rgr_var,sgr_var,sln_var,tex_var do
    begin
      srf_bmp_ptr :=GetBmpHandle(srf_bmp );
      test_bmp_ptr:=GetBmpHandle(test_bmp );
      low_bmp_ptr :=GetBmpHandle(low_bmp );
      low_bmp2_ptr:=GetBmpHandle(low_bmp2);
      if show_tex then
        begin
          tex_bmp_ptr:=GetBmpHandle(tex_bmp );
          tex_bmp.Canvas.Draw(0,0,loaded_picture.Bitmap);
        end;
      SetBkgnd(srf_bmp_ptr,srf_bmp.width,srf_bmp.height,inn_wnd_rct);
    end;
  // Get Target Render For OpenGL Output:
  GLBitmapToRect(texture_id,srf_bmp,down_play_anim_ptr^);
  //if down_play_anim_ptr^ then
  GetObject(srf_bmp.Handle,SizeOf(buffer),@buffer);
end; {$endregion}
{World Axis: Drawing-------------------------}
procedure TSurf.WorldAxisDraw;                                                                                                      inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  WorldAxisBmp(world_axis.x-world_axis_bmp.bmp_ftimg_width_origin >>1,
               world_axis.y-world_axis_bmp.bmp_ftimg_height_origin>>1);
end; {$endregion}
{Align Spline: Calculation-------------------}
procedure TSurf.AlnSplineCalc;                                                                                                      inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with sln_var,sel_var,sgr_var do
    AlignPts
    (
      sln_pts,
      sel_pts_inds,
      sln_pts_cnt,
      sel_pts_cnt
    );
end; {$endregion}
{Select Pivot: Calculation-------------------}
procedure TSurf.SelectPivotCalc;                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  if (not show_spline) then
    Exit;
  with obj_var,srf_var,sln_var,sel_var,pvt_var do
    begin
      SubgraphCalc
      (
        has_sel_pts,
        sln_pts,
        fst_lst_sln_obj_pts,
        sln_obj_ind,
        sln_obj_cnt,
        sln_pts_cnt
      );
      is_not_abst_obj_kind_after:=IsNotAbstObjKindAfter
      (
        kooCurve,
        sel_obj_min_ind
      );
      PivotCalc
      (
        sln_pts,
        sel_pts_inds,
        sel_pts_cnt
      );
      {if (clip_style=csAdvancedClip) then
        begin
          //ncs_adv_clip_rect:=NCSRectCalc(selected_pts_rect,bucket_rect.Width,bucket_rct.Height);
          //AdvancedClipCalc(pts:array of TPointPosF; pts_count:integer; is_pt_marked:aray of boolean);
        end;}
    end;
end; {$endregion}
{Select Pivot: Drawing-----------------------}
procedure TSurf.SelectPivotDraw;                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i,j: integer;
begin
  if (not show_spline) then
    Exit;
  with obj_var,sln_var,sel_var do
    begin
      if (not is_not_abst_obj_kind_after) then
        ClrSplineAll(sel_obj_min_ind,obj_var.obj_cnt-1);
      for i:=0 to sln_obj_cnt-1 do
        begin
          j:=obj_var.obj_arr[obj_var.curve_inds_obj_arr[i]].t_ind;
          if (j>=sel_obj_min_ind) and (j<=obj_var.obj_cnt-1) then
            begin
              if (has_sel_pts[i]<>0) then
                begin
                  {Edges}
                  with eds_img_arr[i],local_prop do
                    if (eds_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) then
                      begin
                        if fst_img.ChkNTValueArr then
                          begin
                            AddSplineEds0(i);
                            CrtSplineEds (i);
                          end;
                        RepSplineEds (i);
                        AddSplineEds3(i);
                        CrtSplineEds (i);
                      end;
                  {Points}
                  with pts_img_arr[i],local_prop do
                    if (pts_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) then
                      begin
                        AddSplineDupPts3(i);
                        RepSplinePts    (i);
                        AddSplinePts3   (i);
                        CrtSplinePts    (i);
                        ClrSplineDupPts3(i);
                      end;
                end;
            end;
        end;
      if (not is_not_abst_obj_kind_after) then
        FilSplineAll(sel_obj_min_ind,obj_var.obj_cnt-1);
      SelPvtAndSplineEdsToBmp;
    end;
end; {$endregion}
{Unselect Pivot: Drawing---------------------}
procedure TSurf.UnselectPivotDraw;                                                                                                  inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i,j: integer;
begin
  if (not show_spline) then
    Exit;
  with obj_var,sln_var,sel_var,crc_sel_var,pvt_var do
    begin
      if (not draw_out_subgraph) and (pvt_draw_sel_eds_off<>pvt) then
        UnselectedPtsCalc1(fst_lst_sln_obj_pts,sln_pts,pvt,pvt_origin);
      if rectangles_calc then
        RctSplineAll1(sel_obj_min_ind,obj_var.obj_cnt-1);
      for i:=0 to sln_obj_cnt-1 do
        begin
          j:=obj_var.obj_arr[obj_var.curve_inds_obj_arr[i]].t_ind;
          if (j>=sel_obj_min_ind) and (j<=obj_var.obj_cnt-1) then
            begin
              if (has_sel_pts[i]<>0) then
                begin
                  {Bounding Rectangles: Edges}
                  with rct_eds_img_arr[i],local_prop do
                    if (rct_eds_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) then
                      begin
                        AddSplineRctEds (i);
                        CrtSplineRctEds (i);
                      end;
                  {Bounding Rectangles: Points}
                  with rct_pts_img_arr[i],local_prop do
                    if (rct_pts_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) then
                      begin
                        AddSplineRctPts (i);
                        CrtSplineRctPts (i);
                      end;
                  {Edges}
                  with eds_img_arr[i],local_prop do
                    if (eds_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) then
                      begin
                        RepSplineEds    (i);
                        AddSplineEds2   (i);
                        CrtSplineEds    (i);
                      end;
                  {Points}
                  with pts_img_arr[i],local_prop do
                    if (pts_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) then
                      begin
                        AddSplineDupPts2(i);
                        RepSplinePts    (i);
                        AddSplinePts2   (i);
                        CrtSplinePts    (i);
                        ClrSplineDupPts2(i);
                      end;
                end;
            end;
        end;
      if (not is_not_abst_obj_kind_after) then
        FilSplineAll(sel_obj_min_ind,obj_var.obj_cnt-1);
      SelPvtAndSplineEdsToBmp;
      SelPtsIndsToFalse;
      FillByte((@has_sel_pts[0])^,Length(has_sel_pts),0);
      crc_sel_rct               :=Default(TRect  );
      pvt                       :=Default(TPtPosF);
      move_pvt                  :=False;
      pvt_to_pt                 :=False;
      pvt_marker_draw           :=False;
      need_align_pivot_x        :=False;
      need_align_pivot_y        :=False;
      need_align_pivot_p        :=False;
      need_align_pivot_p2       :=False;
      is_not_abst_obj_kind_after:=True;
      sel_pts_cnt               :=0;
      outer_subgraph1_eds_cnt   :=0;
      outer_subgraph2_eds_cnt   :=0;
      outer_subgraph3_eds_cnt   :=0;
      inner_subgraph__eds_cnt   :=0;
      sel_bmp.Width             :=0;
      sel_bmp.Height            :=0;
      exp0                      :=(sel_pts_cnt >0);
      exp1                      :=(sel_pts_cnt<>sln_pts_cnt);
      exp2                      :=(sln_pts_cnt >0);
    end;
end; {$endregion}
{Selected Subgraph: Drawing------------------}
procedure TSurf.OuterSubgraphDraw;                                                                                                  inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with sln_var,sel_var,pvt_var do
    OuterSubgraphToBmp(Trunc(pvt.x),
                       Trunc(pvt.y),
                       pvt,
                       sln_pts,
                       srf_bmp_ptr,
                       inn_wnd_rct);
end; {$endregion}
{Selected Subgraph: Drawing------------------}
procedure TSurf.InnerSubgraphDraw;                                                                                                  inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with sln_var,sel_var,pvt_var do
    InnerSubgraphToBmp(Trunc(pvt.x),
                       Trunc(pvt.y),
                       pvt,
                       sln_pts,
                       srf_bmp_ptr,
                       ClippedRct(inn_wnd_rct,sel_pts_rct));
end; {$endregion}
{Selected Points  : Drawing------------------}
procedure TSurf.SelectdPointsDraw;                                                                                                  inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with sln_var,sel_var,pvt_var do
    SelectdPointsToBmp(Trunc(pvt.x),
                       Trunc(pvt.y),
                       pvt,
                       sln_pts,
                       srf_bmp_ptr,
                       inn_wnd_rct);
end; {$endregion}
{Add Spline: Calculation---------------------}
procedure TSurf.AddSplineCalc;                                                                                                      inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  if (not show_spline) then
    Exit;
  with obj_var,sln_var do
    begin
      Add(kooCurve,world_axis_shift);
      SetObjBkgnd
      (
        @obj_arr[obj_cnt-1],
        srf_bmp_ptr,
        srf_bmp.width,
        srf_bmp.height,
        inn_wnd_rct
      );
      AddSplineObj(inn_wnd_rct);
      CreateNode('Spline',IntToStr(obj_var.curve_cnt));
      ObjIndsCalc;
      ScTIndsCalc;
    end;
end; {$endregion}
{Add Spline: Hidden Lines Calc.--------------}
procedure TSurf.AddSplineHdLn;                                                                                                      inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  if (not show_spline) then
    Exit;
  with sln_var do
    begin
      {Edges}
      with eds_img_arr[sln_obj_cnt-1],local_prop do
        if hid_ln_elim then
          begin
            ArrClear     (eds_useless_fld_arr,
                          rct_out_ptr^,
                          srf_bmp.width,
                          0);
            AddSplineEds5(sln_obj_cnt-1);
            ArrFill      (useless_arr,
                          @eds_useless_fld_arr[0],
                          srf_bmp.width,
                          srf_bmp.height,
                          rct_out_ptr^);
          end;
    end;
end; {$endregion}
{Add Spline: Drawing-------------------------}
procedure TSurf.AddSplineDraw;                                                                                                      inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  if (not show_spline) then
    Exit;
  with sln_var do
    begin

      {Bounding Rectangles: Edges}
      with rct_eds_img_arr[sln_obj_cnt-1],local_prop do
        begin
          if rct_eds_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^)) then
            begin
              lazy_repaint_prev:=IsRct1InRct2(rct_ent,rct_out_ptr^);
              AddSplineRctEds(sln_obj_cnt-1);
              CrtSplineRctEds(sln_obj_cnt-1);
            end
          else
            lazy_repaint_prev:=False;
        end;

      {Bounding Rectangles: Points}
      with rct_pts_img_arr[sln_obj_cnt-1],local_prop do
        begin
          if rct_pts_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^)) then
            begin
              lazy_repaint_prev:=IsRct1InRct2(rct_ent,rct_out_ptr^);
              AddSplineRctPts(sln_obj_cnt-1);
              CrtSplineRctPts(sln_obj_cnt-1);
            end
          else
            lazy_repaint_prev:=False;
        end;

      {Edges}
      with eds_img_arr[sln_obj_cnt-1],local_prop do
        begin
          if eds_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^)) then
            begin
              lazy_repaint_prev:=IsRct1InRct2(rct_ent,rct_out_ptr^);
              if byte_mode then
                begin
                  if hid_ln_elim then
                    AddSplineEds7(sln_obj_cnt-1)
                  else
                    AddSplineEds6(sln_obj_cnt-1);
                end
              else
                begin
                  if hid_ln_elim then
                    AddSplineEds4(sln_obj_cnt-1)
                  else
                    AddSplineEds0(sln_obj_cnt-1);
                end;
              CrtSplineEds   (sln_obj_cnt-1);
            end
          else
            lazy_repaint_prev:=False;
        end;

      {Points}
      with pts_img_arr[sln_obj_cnt-1],local_prop do
        begin
          if pts_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^)) then
            begin
              lazy_repaint_prev:=IsRct1InRct2(rct_ent,rct_out_ptr^);
              AddSplineDupPts0(sln_obj_cnt-1);
              if byte_mode then
                AddSplinePts4 (sln_obj_cnt-1)
              else
                AddSplinePts0 (sln_obj_cnt-1);
              CrtSplinePts    (sln_obj_cnt-1);
              ClrSplineDupPts0(sln_obj_cnt-1);
            end
          else
            lazy_repaint_prev:=False;
        end;

    end;
end; {$endregion}
{Add Tile Map: Calculation-------------------}
procedure TSurf.AddTileMapCalc;                                                                                                     inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  if (not show_tile_map) then
    Exit;
  with obj_var,tlm_var do
    begin
      Add(kooTlMap,world_axis_shift);
      SetObjBkgnd
      (
        @obj_arr[obj_cnt-1],
        srf_bmp_ptr,
        srf_bmp.width,
        srf_bmp.height,
        inn_wnd_rct
      );
      AddTileMapObj(inn_wnd_rct);
      CreateNode('Tile Map',IntToStr(obj_var.tlmap_cnt));
      ObjIndsCalc;
      ScTIndsCalc;
    end;
end; {$endregion}
{Scale Background: Calculation---------------}
procedure TSurf.SclBckgdCalc;                                                                                                       inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with srf_var do
    PtsScl
    (
      PtPosF(world_axis.x,
             world_axis.y),
      tex_var.tex_bmp_rct_pts,
      2,
      PtPosF(DEFAULT_SCL_MUL,
             DEFAULT_SCL_MUL),
      scl_dir
    );
end; {$endregion}
{Scale Spline: Calculation-------------------}
procedure TSurf.SclSplineCalc;                                                                                                      inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with sln_var do
    PtsScl
    (
      PtPosF(world_axis.x,
             world_axis.y),
      sln_pts,
      sln_pts_cnt,
      PtPosF(DEFAULT_SCL_MUL,
             DEFAULT_SCL_MUL),
      scl_dir
    );
end; {$endregion}
{Repaint Splines with Hidden Lines-----------}
procedure TSurf.RepSplineHdLn;                                                                                                      inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  eds_var_ptr            : PFastLine;
  eds_useless_fld_arr_ptr: PInteger;
  i                      : integer;
begin
  if (not show_spline) then
    Exit;
  with obj_var,sln_var do
    begin
      eds_var_ptr            :=Unaligned(@eds_img_arr        [0]);
      eds_useless_fld_arr_ptr:=Unaligned(@eds_useless_fld_arr[0]);
      for i:=0 to sln_obj_cnt-1 do
        with (eds_var_ptr+i)^,local_prop do
          if hid_ln_elim then
            begin
              ArrClear     (eds_useless_fld_arr,
                            rct_out_ptr^,
                            srf_bmp.width,
                            0);
              AddSplineEds5(i);
              ArrFill      (useless_arr,
                            eds_useless_fld_arr_ptr,
                            srf_bmp.width,
                            srf_bmp.height,
                            rct_out_ptr^);
            end;
    end;
end; {$endregion}
{Repaint Spline: Drawing---------------------}
procedure TSurf.RepSplineDraw0;                                                                                                     inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rct_eds_var_ptr: PFastLine;
  rct_pts_var_ptr: PFastLine;
      eds_var_ptr: PFastLine;
      pts_var_ptr: PFastLine;
  has_sel_pts_ptr: PByte;
  i              : integer;
  b              : boolean;
  b0 ,b1 ,b2 ,b3 : boolean;
  b0_,b1_,b2_,b3_: boolean;
begin
  if (not show_spline) then
    Exit;
  with obj_var,sln_var do
    begin
      if rectangles_calc then
        RctSplineAll2(0,obj_var.obj_cnt-1){RctSplineAll0(0,sln_obj_cnt-1)};
      rct_eds_var_ptr:=Unaligned(@rct_eds_img_arr[0]);
      rct_pts_var_ptr:=Unaligned(@rct_pts_img_arr[0]);
          eds_var_ptr:=Unaligned(@    eds_img_arr[0]);
          pts_var_ptr:=Unaligned(@    pts_img_arr[0]);
      has_sel_pts_ptr:=Unaligned(@has_sel_pts    [0]);
      b              :=spline_scale_calc or form_resize_calc or ((not repaint_spline_hid_ln_calc1) and repaint_spline_hid_ln_calc2);
      for i:=0 to sln_obj_cnt-1 do
        begin

          {Bounding Rectangles: Edges}
          with (rct_eds_var_ptr+i)^,local_prop do
            begin
              if (rct_eds_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) then
                begin
                  b0 :=IsRct1InRct2(rct_ent,rct_out_ptr^);
                  b0_:=(not b0){clipped} or (b0 and (not lazy_repaint_prev)){not clipped, in window} or b or (not lazy_repaint);
                  if b0_ then
                    begin
                      if free_mem_on_scale_down and (fst_img<>Nil) then
                        fst_img.ClrArr;
                      AddSplineRctEds(i);
                      CrtSplineRctEds(i);
                    end;
                  lazy_repaint_prev:=b0;
                end
              else
                begin
                  if free_mem_on_out_of_wnd and (fst_img<>Nil) then
                    fst_img.ClrArr;
                  lazy_repaint_prev:=False;
                end;
            end;

          {Bounding Rectangles: Points}
          with (rct_pts_var_ptr+i)^,local_prop do
            begin
              if (rct_pts_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) then
                begin
                  b1 :=IsRct1InRct2(rct_ent,rct_out_ptr^);
                  b1_:=(not b1){clipped} or (b1 and (not lazy_repaint_prev)){not clipped, in window} or b or (not lazy_repaint);
                  if b1_ then
                    begin
                      if free_mem_on_scale_down and (fst_img<>Nil) then
                        fst_img.ClrArr;
                      AddSplineRctPts(i);
                      CrtSplineRctPts(i);
                    end;
                  lazy_repaint_prev:=b1;
                end
              else
                begin
                  if free_mem_on_out_of_wnd and (fst_img<>Nil) then
                    fst_img.ClrArr;
                  lazy_repaint_prev:=False;
                end;
            end;

          {Edges}
          with (eds_var_ptr+i)^,local_prop do
            begin
              if (eds_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) then
                begin
                  b2 :=IsRct1InRct2(rct_ent,rct_out_ptr^);
                  b2_:=(not b2){clipped} or (b2 and (not lazy_repaint_prev)){not clipped, in window} or b or (not lazy_repaint);
                  if b2_ then
                    begin
                      if free_mem_on_scale_down and (fst_img<>Nil) then
                        fst_img.ClrArr;
                      if ((has_sel_pts_ptr+i)^=0) then
                        begin
                          if byte_mode then
                            begin
                              if hid_ln_elim then
                                AddSplineEds7(i)
                              else
                                AddSplineEds6(i);
                            end
                          else
                            begin
                              if (not hid_ln_elim) then
                                AddSplineEds0(i)
                              else
                                AddSplineEds4(i);
                            end;
                        end
                      else
                        AddSplineEds1(i);
                      CrtSplineEds(i);
                    end;
                  lazy_repaint_prev:=b2;
                end
              else
                begin
                  if free_mem_on_out_of_wnd and (fst_img<>Nil) then
                    fst_img.ClrArr;
                  lazy_repaint_prev:=False;
                end;
            end;

          {Points}
          with (pts_var_ptr+i)^,local_prop do
            begin
              if (pts_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) then
                begin
                  b3 :=IsRct1InRct2(rct_ent,rct_out_ptr^);
                  b3_:=(not b3){clipped} or (b3 and (not lazy_repaint_prev)){not clipped, in window} or b or (not lazy_repaint);
                  if b3_ then
                    begin
                      if free_mem_on_scale_down and (fst_img<>Nil) then
                        fst_img.ClrArr;
                      if ((has_sel_pts_ptr+i)^=0) then
                        begin
                          AddSplineDupPts0(i);
                          if byte_mode then
                            AddSplinePts4 (i)
                          else
                            AddSplinePts0 (i);
                          ClrSplineDupPts0(i);
                        end
                      else
                        begin
                          AddSplineDupPts1(i);
                          if byte_mode then
                            AddSplinePts5 (i)
                          else
                            AddSplinePts1 (i);
                          ClrSplineDupPts1(i);
                        end;
                      CrtSplinePts(i);
                    end;
                  lazy_repaint_prev:=b3;
                end
              else
                begin
                  if free_mem_on_out_of_wnd and (fst_img<>Nil) then
                    fst_img.ClrArr;
                  lazy_repaint_prev:=False;
                end;
            end;

        end;
    end;
end; {$endregion}
procedure TSurf.RepSplineDraw1;                                                                                                     inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rct_eds_var_ptr: PFastLine;
  rct_pts_var_ptr: PFastLine;
      eds_var_ptr: PFastLine;
      pts_var_ptr: PFastLine;
  has_sel_pts_ptr: PByte;
  i              : integer;
  b              : boolean;
  b0 ,b1 ,b2 ,b3 : boolean;
  b0_,b1_,b2_,b3_: boolean;
begin
  if (not show_spline) then
    Exit;
  with obj_var,sln_var do
    begin
      if rectangles_calc then
        RctSplineAll2(0,obj_var.obj_cnt-1){RctSplineAll0(0,sln_obj_cnt-1)};
      rct_eds_var_ptr:=Unaligned(@rct_eds_img_arr[0]);
      rct_pts_var_ptr:=Unaligned(@rct_pts_img_arr[0]);
          eds_var_ptr:=Unaligned(@    eds_img_arr[0]);
          pts_var_ptr:=Unaligned(@    pts_img_arr[0]);
      has_sel_pts_ptr:=Unaligned(@has_sel_pts    [0]);
      b              :=spline_scale_calc or form_resize_calc or {rep_hid_ln_elim_first}(not repaint_spline_hid_ln_calc2);
      rep_hid_ln_elim_first:=False;
      for i:=0 to sln_obj_cnt-1 do
        begin

          {Bounding Rectangles: Edges}
          with (rct_eds_var_ptr+i)^,local_prop do
            begin
              if (rct_eds_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) then
                begin
                  b0 :=IsRct1InRct2(rct_ent,rct_out_ptr^);
                  b0_:=(not b0){clipped} or (b0 and (not lazy_repaint_prev)){not clipped, in window} or b or (not lazy_repaint);
                  if b0_ then
                    begin
                      if free_mem_on_scale_down and (fst_img<>Nil) then
                        fst_img.ClrArr;
                      AddSplineRctEds(i);
                      CrtSplineRctEds(i);
                    end;
                  lazy_repaint_prev:=b0;
                end
              else
                begin
                  if free_mem_on_out_of_wnd and (fst_img<>Nil) then
                    fst_img.ClrArr;
                  lazy_repaint_prev:=False;
                end;
            end;

          {Bounding Rectangles: Points}
          with (rct_pts_var_ptr+i)^,local_prop do
            begin
              if (rct_pts_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) then
                begin
                  b1 :=IsRct1InRct2(rct_ent,rct_out_ptr^);
                  b1_:=(not b1){clipped} or (b1 and (not lazy_repaint_prev)){not clipped, in window} or b or (not lazy_repaint);
                  if b1_ then
                    begin
                      if free_mem_on_scale_down and (fst_img<>Nil) then
                        fst_img.ClrArr;
                      AddSplineRctPts(i);
                      CrtSplineRctPts(i);
                    end;
                  lazy_repaint_prev:=b1;
                end
              else
                begin
                  if free_mem_on_out_of_wnd and (fst_img<>Nil) then
                    fst_img.ClrArr;
                  lazy_repaint_prev:=False;
                end;
            end;

          {Edges}
          with (eds_var_ptr+i)^,local_prop do
            begin
              if (eds_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) then
                begin
                  b2 :=IsRct1InRct2(rct_ent,rct_out_ptr^);
                  b2_:=(not b2){clipped} or (b2 and (not lazy_repaint_prev)){not clipped, in window} or b or (not lazy_repaint);
                  if b2_ then
                    begin
                      if free_mem_on_scale_down and (fst_img<>Nil) then
                        fst_img.ClrArr;
                      if ((has_sel_pts_ptr+i)^=0) then
                        AddSplineEds0(i)
                      else
                        AddSplineEds1(i);
                      CrtSplineEds   (i);
                    end;
                  lazy_repaint_prev:=b2;
                end
              else
                begin
                  if free_mem_on_out_of_wnd and (fst_img<>Nil) then
                    fst_img.ClrArr;
                  lazy_repaint_prev:=False;
                end;
            end;

          {Points}
          with (pts_var_ptr+i)^,local_prop do
            begin
              if (pts_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) then
                begin
                  b3 :=IsRct1InRct2(rct_ent,rct_out_ptr^);
                  b3_:=(not b3){clipped} or (b3 and (not lazy_repaint_prev)){not clipped, in window} or b or (not lazy_repaint);
                  if b3_ then
                    begin
                      if free_mem_on_scale_down and (fst_img<>Nil) then
                        fst_img.ClrArr;
                      if ((has_sel_pts_ptr+i)^=0) then
                        begin
                          AddSplineDupPts0(i);
                          AddSplinePts0   (i);
                          ClrSplineDupPts0(i);
                        end
                      else
                        begin
                          AddSplineDupPts1(i);
                          AddSplinePts1   (i);
                          ClrSplineDupPts1(i);
                        end;
                      CrtSplinePts(i);
                    end;
                  lazy_repaint_prev:=b3;
                end
              else
                begin
                  if free_mem_on_out_of_wnd and (fst_img<>Nil) then
                    fst_img.ClrArr;
                  lazy_repaint_prev:=False;
                end;
            end;

        end;
    end;
end; {$endregion}
{Duplicated Points: Drawing------------------}
procedure TSurf.DupPtsDraw;                                                                                                         inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with sln_var do
    ArrFill(dup_pts_arr,srf_bmp_ptr,srf_bmp.width,srf_bmp.height,inn_wnd_rct,clGreen);
end; {$endregion}
{World Axis: Reset Background Settings-------}
procedure TSurf.WAxSetBckgd;                                                                                                        inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  world_axis_bmp.SetBkgnd(srf_bmp_ptr,srf_bmp.width,srf_bmp.height);
end; {$endregion}
{Selected Subgraph: Drawing------------------}
procedure TSurf.SelectedSubgrtaphDraw;                                                                                              inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with sel_var do
    begin
      if draw_out_subgraph then
        OuterSubgraphDraw;
      if draw_inn_subgraph and (not IsRct1OutOfRct2(sel_pts_rct,inn_wnd_rct)) then
        InnerSubgraphDraw;
      if draw_selected_pts then
        SelectdPointsDraw;
    end;
end; {$endregion}
{Sel. Tools Marker: Reset Background Settings}
procedure TSurf.STMSetBckgd;                                                                                                        inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  pvt_var.sel_tls_mrk.SetBkgnd(srf_bmp_ptr,srf_bmp.width,srf_bmp.height);
end; {$endregion}
{Actors: Reset Background Settings-----------}
procedure TSurf.ActSetBckgd;                                                                                                        inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  fast_actor_set_var.d_icon.SetBkgnd(srf_bmp_ptr,srf_bmp.width,srf_bmp.height);
end; {$endregion}
{TimeLine: Reset Background Settings---------}
procedure TSurf.TLnSetBkgnd;                                                                                                        inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  for i:=0 to 3 do
    bckgd_btn_arr[i].SetBkgnd(srf_bmp_ptr,srf_bmp.width,srf_bmp.height);
  for i:=0 to 5 do
    tmln_btn_arr[i].SetBkgnd(srf_bmp_ptr,srf_bmp.width,srf_bmp.height);
end; {$endregion}
{Cursors: Reset Background Settings----------}
procedure TSurf.CurSetBkgnd;                                                                                                        inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  cur_arr[0].SetBkgnd(srf_bmp_ptr,srf_bmp.width,srf_bmp.height);
end; {$endregion}
{Background Post-Processing------------------}
procedure TSurf.BkgPP;                                                                                                              inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i:integer;
begin
  if (bkg_style=bsGrayscale) or (bkg_style=bsBoth) then
    PPGrayscaleR(srf_bmp_ptr,inn_wnd_rct,srf_bmp.width);
  if (bkg_style=bsBlur) or (bkg_style=bsBoth) then
    for i:=0 to pp_iters_cnt-1 do
      PPBlur(srf_bmp_ptr,inn_wnd_rct,srf_bmp.width);
end; {$endregion}
{Grid Post-Processing------------------------}
procedure TSurf.GrdPP;                                                                                                              inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  for i:=0 to 1 do
    PPBlur(srf_bmp_ptr,
           inn_wnd_rct,
           srf_bmp.width,
           11);
end; {$endregion}
{Main Render Procedure}
procedure TSurf.MainDraw;                                                                                                                   {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i             : byte;
  execution_time: double;
begin

  exec_timer:=TPerformanceTime.Create;
  exec_timer.Start;

  {Calculation of Some Expressions}
  if (sel_var<>Nil) then
    begin
      exp0               :=(sel_var.sel_pts_cnt>0);
      sel_var.sel_pts    :=sel_var.sel_pts   and exp0;
      sel_eds_draw_calc  :=sel_eds_draw_calc and exp0;
      bkg_pp_calc        :=bkg_pp_calc       and exp0;
    end;
  if (sln_var<>Nil) then
    begin
      exp2               :=(sln_var.sln_pts_cnt>0);
      repaint_spline_calc:=repaint_spline_calc and exp2;
    end;
  if (down_play_anim_ptr<>Nil) then
    begin
      timeline_draw      :=      (down_play_anim_ptr^);
      cursor_draw        :=      (down_play_anim_ptr^);
    //world_axis_draw    :=({not }down_play_anim_ptr^){ and world_axis_draw};
    end;

  {Rectangles----------------------------} {$region -fold}
  if main_bmp_rect_calc then
    MainBmpRectCalc; {$endregion}

  {Sizes---------------------------------} {$region -fold}
  if main_bmp_size_calc then
    MainBmpSizeCalc; {$endregion}

  {Handles ------------------------------} {$region -fold}
    if form_resize_calc then
      GetHandles; {$endregion}

  {Arrays--------------------------------} {$region -fold}
  if main_bmp_arrs_calc then
    MainBmpArrsCalc; {$endregion}

  {Background Settings: World Axis-------} {$region -fold}
  if world_axis_set_bckgd then
    WAxSetBckgd; {$endregion}

  {Background Settings: Sel. Tools Marker} {$region -fold}
  if sel_tls_mrk_set_bckgd then
    STMSetBckgd; {$endregion}

  {Background Settings: Actors-----------} {$region -fold}
  if actor_set_bckgd then
    ActSetBckgd; {$endregion}

  {Background Settings: TimeLine---------} {$region -fold}
  if timeline_set_bkgnd then
    TLnSetBkgnd; {$endregion}

  {Background Settings: Cursors----------} {$region -fold}
  if cursors_set_bkgnd then
    CurSetBkgnd; {$endregion}

  {Scale Background----------------------} {$region -fold}
    if bckgd_scale_calc then
      SclBckgdCalc; {$endregion}

  {Add Spline----------------------------} {$region -fold}
  if add_spline_calc then
    AddSplineCalc; {$endregion}

  {Scale Splines-------------------------} {$region -fold}
  if spline_scale_calc then
    SclSplineCalc; {$endregion}

  {Align Splines-------------------------} {$region -fold}
  if sgr_var.align_pts and align_pts_calc then
    AlnSplineCalc; {$endregion}

  {Add Tile Map--------------------------} {$region -fold}
  if add_tlmap_calc then
    AddTileMapCalc; {$endregion}

  {Select Pivot--------------------------} {$region -fold}
  if sel_var.sel_pts then
    SelectPivotCalc; {$endregion}

  need_repaint:=True;

  {Select Pivot-------------------------------------} {$region -fold}
  if sel_var.sel_pts then
    //if (not pvt_var.move_pvt) then
      SelectPivotDraw; {$endregion}

  {Unselect Pivot-----------------------------------} {$region -fold}
  if unselect_pivot_calc then
    UnselectPivotDraw; {$endregion}

  {Add Spline: Hidden Lines Calc.-------------------} {$region -fold}
    if add_hid_ln_calc then
      AddSplineHdLn; {$endregion}

  {Add Spline---------------------------------------} {$region -fold}
  if add_spline_calc then
    AddSplineDraw; {$endregion}

  {Repaint Splines: Hidden Lines--------------------} {$region -fold}
  if repaint_spline_hid_ln_calc0 then
    RepSplineHdLn; {$endregion}

  {Repaint Splines----------------------------------} {$region -fold}
  if repaint_spline_calc then
    begin
      if down_select_points_ptr^ then
        RepSplineDraw1
      else
        RepSplineDraw0;
    end; {$endregion}

  {Scene Drawing------------------------------------} {$region -fold}
  if (fill_scene_calc and sel_var.is_not_abst_obj_kind_after) or
      form_resize_calc                                        or
      bckgd_scale_calc                                        then
    obj_var.FilScene; {$endregion}

  {World Axis---------------------------------------} {$region -fold}
  {if world_axis_draw and exp0 then
    WorldAxisDraw;} {$endregion}

  {Post-Processing----------------------------------} {$region -fold}
  {GrdPP;} {$endregion}

  {Duplicated Points--------------------------------} {$region -fold}
  {DupPtsDraw;} {$endregion}

  {Background Post-Processing After Points Selection} {$region -fold}
  if bkg_pp_calc then
    BkgPP; {$endregion}

  {Inner Window Rectangle---------------------------} {$region -fold}
  if (inn_wnd_mrg>0) then
    InnerWindowDraw($00FF9F66); {$endregion}

  {Copy Main Buffer To Lower Buffer-----------------} {$region -fold}
  MainBmpToLowerBmp; {$endregion}

  {World Axis---------------------------------------} {$region -fold}
  if world_axis_draw and (not exp0) then
    WorldAxisDraw; {$endregion}

  {Selected Subgrtaph-------------------------------} {$region -fold}
  if sel_eds_draw_calc then
    SelectedSubgrtaphDraw; {$endregion}

  {Pivot--------------------------------------------} {$region -fold}
  if exp0 then
    pvt_var.PivotDraw(PtPos(0,0)); {$endregion}

  {Copy Main Buffer To Lower Buffer-----------------} {$region -fold}
  if sel_var.sel_pts{ and (not pvt_var.move_pvt)} then
    MainBmpToLowerBmp2; {$endregion}

  {Circle Selection---------------------------------} {$region -fold}
  {$endregion}

  {TimeLine Buttons---------------------------------} {$region -fold}
  {if timeline_draw then
    TimeLineButtonsDraw(F_MainForm.S_Splitter2.Top-40,F_MainForm.S_Splitter2.Width>>1-16+4);} {$endregion}

  {Cursor-------------------------------------------} {$region -fold}
  if cursor_draw then
    CursorDraw; {$endregion}

  {Invalidate Drawing Area(Editor Inner Window)-----} {$region -fold}
  if (not down_play_anim_ptr^) then
    {CnvToCnv(srf_bmp_rct,F_MainForm.Canvas,srf_bmp.Canvas,SRCCOPY);}
    InvalidateInnerWindow; {$endregion}

  need_repaint:=False;

(******************************************************************************)

  exec_timer.Stop;
  execution_time:=Trunc(exec_timer.Delay*1000);

  {Log.}
  DrawObjectInfo0;
  DrawObjectInfo1
  (
    inn_wnd_rct.right -170,
    inn_wnd_rct.bottom-030,
    srf_bmp,
    'Execution time: '+FloatToStr(execution_time)+' ms.'
  );

end; {$endregion}
procedure TSurf.EventGroupsCalc(var arr:TBool2Arr; event_group:TEventGroupEnum);                                                            {$ifdef Linux}[local];{$endif} {$region -fold}
var
  b: byte;
begin
  for b in event_group do
    arr[b]:=True;
  MainDraw;
  for b in event_group do
    arr[b]:=False;
end; {$endregion}

// (Main Layer Instance) Копия основного слоя:
constructor TSurfInst.Create(w,h:TColor); {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  bmp_rect:=PtBounds(0,0,w,h);
end; {$endregion}
destructor  TSurfInst.Destroy;            {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  inherited Destroy;
end; {$endregion}
{$endregion}

// (Texture) Текстура:
{LI} {$region -fold}
constructor TTex.Create(w,h:TColor);                                   {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  obj_var.Add(kooBkTex,srf_var.world_axis_shift); 
  CreateNode('Background Texture','');
  ObjIndsCalc;
  ScTIndsCalc;
  SetLength(tex_bmp_rct_pts       ,2);
  SetLength(tex_bmp_rct_origin_pts,2);
  SetLength(tex_list              ,8); // Выделение памяти для массива текстур
  with srf_var do
    begin
      tex_bmp_rct_origin_pts[0].x:=296{Trunc(inn_wnd_rct.left+inn_wnd_rct.right -w)>>1};
      tex_bmp_rct_origin_pts[0].y:=034{Trunc(inn_wnd_rct.top +inn_wnd_rct.bottom-h)>>1};
      tex_bmp_rct_origin_pts[1].x:=tex_bmp_rct_origin_pts[0].x+w;
      tex_bmp_rct_origin_pts[1].y:=tex_bmp_rct_origin_pts[0].y+h;
      tex_bmp_rct_pts            :=tex_bmp_rct_origin_pts;
    end;
  loaded_picture    :=TPicture.Create;
  tex_bmp           :=Graphics.TBitmap.Create;
  tex_bmp.Width     :=w;
  tex_bmp.Height    :=h;
  tex_list_item_size:=256;
  show_tex          :=True;
end; {$endregion}
destructor TTex.Destroy;                                               {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  inherited Destroy;
end; {$endregion}
procedure CreateTextureList;                                           {$ifdef Linux}[local];{$endif} {$region -fold}
var
  texture_list_item        : TSpeedButton;
  texture_list_item_picture: Graphics.TBitmap;
begin
  F_MainForm.FP_Image_List.Caption:='';
  texture_list_item        :=TSpeedButton.Create(Nil);
  texture_list_item_picture:=Graphics.TBitmap.Create;
  with texture_list_item,srf_var,tex_var do
    begin
      texture_list_item.OnMouseDown:=@F_MainForm.TextureListItemMouseDown;
      BorderSpacing.Around:=2;
      Color               :=$00A6A6A6;
      AllowAllUp          :=True;
      Flat                :=True;
      Transparent         :=False;
      Width               :=tex_list_item_size;
      Height              :=tex_list_item_size;
      Parent              :=F_MainForm.FP_Image_List;
      if (loaded_picture.Width=loaded_picture.height) then
        with texture_list_item_picture do
          begin
            width :=tex_list_item_size-6;
            height:=width;
          end;
      if (loaded_picture.width>loaded_picture.height) then
        with texture_list_item_picture do
          begin
            width :=tex_list_item_size-6;
            height:=Trunc((loaded_picture.height*width)/loaded_picture.width);
          end;
      if (loaded_picture.width<loaded_picture.height) then
        with texture_list_item_picture do
          begin
            height:=tex_list_item_size-6;
            width :=Trunc((loaded_picture.width*height)/loaded_picture.height);
          end;
      texture_list_item_picture.Canvas.StretchDraw(Rect(0,0,
                                                        texture_list_item_picture.width,
                                                        texture_list_item_picture.height),
                                                   loaded_picture.Graphic);
      Glyph.width :=tex_list_item_size-6;
      Glyph.height:=tex_list_item_size-6;
      Glyph       :=texture_list_item_picture;
    end;
end; {$endregion}
procedure TTex.LoadTexture;                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with srf_var do
    begin
      F_MainForm.SB_StatusBar1.Panels.Items[2].Text:='  '+F_MainForm.OpenPictureDialog1.Filename;
      CreateTextureList;
      is_tex_enabled:=True;
      AlignPictureToCenter;
      if down_select_points_ptr^ then
        begin
          crc_sel_var.crc_sel_rct:=Default(TRect);
          rct_sel_var.rct_sel    :=Default(TRect);
        end;
      tex_bmp_ptr   :=GetBmpHandle(tex_bmp);
      tex_bmp.width :=Trunc(tex_bmp_rct_pts[1].x-tex_bmp_rct_pts[0].x);
      tex_bmp.height:=Trunc(tex_bmp_rct_pts[1].y-tex_bmp_rct_pts[0].y);
      tex_bmp.Canvas.Draw(0,0,loaded_picture.Bitmap);
      EventGroupsCalc(calc_arr,[6,8,9,18,23,30,31,32]);
    end;
end; {$endregion}
procedure TTex.TexToBmp(rect_dst:TPtRect; canvas_dst:TCanvas); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with canvas_dst,rect_dst do
    if is_tex_enabled then
      StretchDraw
      (
        Rect
        (
          left,
          top,
          right,
          bottom
        ),
        tex_bmp
      );
end; {$endregion}
procedure TTex.AlignPictureToCenter;                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  tex_bmp_rct_width,tex_bmp_rct_height: integer;
begin
  if is_tex_enabled then
    begin
      tex_bmp_rct_width :=loaded_picture.width;
      tex_bmp_rct_height:=loaded_picture.height;
    end
  else
    begin
      tex_bmp_rct_width :={512}Trunc(tex_bmp_rct_origin_pts[1].x)-Trunc(tex_bmp_rct_origin_pts[0].x);
      tex_bmp_rct_height:={512}Trunc(tex_bmp_rct_origin_pts[1].y)-Trunc(tex_bmp_rct_origin_pts[0].y);
    end;
  tex_bmp_rct_pts[0].x:=((splitters_arr[1]^   +
                          splitters_arr[3]^   -
                          tex_bmp_rct_width+
                          splitter_thickness)/2);
  tex_bmp_rct_pts[0].y:=((splitters_arr[5]^    +
                          splitters_arr[2]^    -
                          tex_bmp_rct_height+
                          splitter_thickness)/2);
  tex_bmp_rct_pts[1].x:=tex_bmp_rct_pts[0].x+tex_bmp_rct_width ;
  tex_bmp_rct_pts[1].y:=tex_bmp_rct_pts[0].y+tex_bmp_rct_height;
end; {$endregion}
procedure TTex.FilBkTexObj(constref bktex_ind:TColor);         inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  if show_tex then
    with obj_var.obj_arr[obj_var.bktex_inds_obj_arr[bktex_ind]] do
      TexToBmp(PtRct(tex_bmp_rct_pts),srf_var.srf_bmp.Canvas);
end; {$endregion}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.TextureListItemMouseDown(sender:TObject; button:TMouseButton; shift:TShiftState; x,y:integer); {$region -fold}
var
  item_index,i,j: integer;
begin
  item_index:=Trunc(tex_list_item_pos_x/tex_var.tex_list_item_size);
  if (item_index<=FP_Image_List.ControlCount-1) then
    begin
      (FP_Image_List.Controls[item_index] as TSpeedButton).Color:=$00884E2B;
      for i:=0 to item_index-1 do
        (FP_Image_List.Controls[i] as TSpeedButton).Color:=$00A6A6A6;
      for j:=item_index+1 to FP_Image_List.ControlCount-1 do
        (FP_Image_List.Controls[j] as TSpeedButton).Color:=$00A6A6A6;
    end;
end; {$endregion}
procedure TF_MainForm.SB_Load_ImageClick      (sender:TObject);                                                      {$region -fold}
begin
  SB_Load_Image.Down:=False;
  OpenPictureDialog1.Options:=OpenPictureDialog1.Options+[ofFileMustExist];
  if (not OpenPictureDialog1.Execute) then
    Exit;
  try
    tex_var.loaded_picture.LoadFromFile(OpenPictureDialog1.Filename);
  except
    on E: Exception do
      MessageDlg('Error','Error: '+E.Message,mtError,[mbOk],0);
  end;
  tex_var.LoadTexture;
  MI_Antialiasing.Checked:=True;
  srf_var.srf_bmp.Canvas.Antialiasingmode:=amOn;
end; {$endregion}
procedure TF_MainForm.SB_Save_ImageClick      (sender:TObject);                                                      {$region -fold}
begin
  SB_Save_Image.Down:=False;
  if tex_var.loaded_picture.Graphic=Nil then
    begin
      MessageDlg('No image','Please open an image, before save',mtError,[mbOk],0);
      Exit;
    end;
  SavePictureDialog1.Options:=SavePictureDialog1.Options+[ofPathMustExist];
  if (not SavePictureDialog1.Execute) then
    Exit;
  try
    tex_var.loaded_picture.SaveToFile(SavePictureDialog1.Filename);
  except
    on E: Exception do
      MessageDlg('Error','Error: '+E.Message,mtError,[mbOk],0);
  end;
end; {$endregion}
{$endregion}

// (Grid) Сетка:
{LI} {$region -fold}
constructor TRGrid.Create(w,h:TColor);                                                                                                      {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  obj_var.Add(kooRGrid,srf_var.world_axis_shift);
  CreateNode('Regular Grid','');
  ObjIndsCalc;
  ScTIndsCalc;
  rgrid_dnt  :=64;
  rgrid_color:=$00ABAFA3;
  show_grid  :=True;
end; {$endregion}
destructor  TRGrid.Destroy;                                                                                                                 {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  inherited Destroy;
end; {$endregion}
procedure   TRGrid.RGridToBmp(constref pvt:TPtPosF; constref bmp_dst_ptr:PInteger; constref bmp_dst_width:TColor; rct_clp:TPtRect); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sht_pow_mul  : double;
  w_inc,h_inc  : double;
  i,x0,y0,x1,y1: integer;
begin
  with rct_clp do
    begin
      sht_pow_mul:=rgrid_dnt*Power(DEFAULT_SCL_MUL,srf_var.scl_dif);

      // Horizontal Lines:
      x0   :=left;
      x1   :=left+width;
      h_inc:=0;
      for i:=0 to Trunc((pvt.y-top)/sht_pow_mul) do
        begin
          y0:=Trunc(pvt.y-h_inc);
          if LineHC(x0,y0,x1,rct_clp) then
             LineH (x0,y0,x1,bmp_dst_ptr,bmp_dst_width,{clRed}rgrid_color);
          h_inc+=sht_pow_mul;
        end;
      h_inc:=sht_pow_mul;
      for i:=0 to Trunc((bottom-pvt.y)/sht_pow_mul)-1 do
        begin
          y0:=Trunc(pvt.y+h_inc);
          if LineHC(x0,y0,x1,rct_clp) then
             LineH (x0,y0,x1,bmp_dst_ptr,bmp_dst_width,{clGreen}rgrid_color);
          h_inc+=sht_pow_mul;
        end;

      // Vertical Lines:
      y0   :=top;
      y1   :=top+height;
      w_inc:=0;
      for i:=0 to Trunc((pvt.x-left)/sht_pow_mul) do
        begin
          x0:=Trunc(pvt.x-w_inc);
          if LineVC(x0,y0,y1,rct_clp) then
             LineV (x0,y0,y1,bmp_dst_ptr,bmp_dst_width,{clWhite}rgrid_color);
          w_inc+=sht_pow_mul;
        end;
      w_inc:=sht_pow_mul;
      for i:=0 to Trunc((right-pvt.x)/sht_pow_mul)-1 do
        begin
          x0:=Trunc(pvt.x+w_inc);
          if LineVC(x0,y0,y1,rct_clp) then
             LineV (x0,y0,y1,bmp_dst_ptr,bmp_dst_width,{clBlack}rgrid_color);
          w_inc+=sht_pow_mul;
        end;

    end;
end; {$endregion}
procedure   TRGrid.FilRGridObj(constref rgrid_ind:TColor);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
begin
  with srf_var do
    if show_grid then
      begin
        obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.rgrid_inds_obj_arr[rgrid_ind]]);
        with obj_arr_ptr^ do
          RGridToBmp(PtPosF(world_axis.x+world_axis_shift.x,
                            world_axis.y+world_axis_shift.y),
                            bkgnd_ptr,
                            bkgnd_width,
                            rct_clp);
      end;
end; {$endregion}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.SB_RGridClick      (sender:TObject);                                                                                                                  {$region -fold}
begin
  DrawingPanelsSetVisibility1(down_rgrid_ptr,P_RGrid,P_Draw_Custom_Panel,prev_panel_draw,curr_panel_draw);
  DrawingPanelsSetVisibility2;
end; {$endregion}
procedure TF_MainForm.SB_RGrid_ColorClick(sender:TObject);                                                                                                                  {$region -fold}
begin
  CD_Select_Color.Color:=SB_RGrid_Color.Color;
  CD_Select_Color.Execute;
  rgr_var.rgrid_color  :=SetColorInv(CD_Select_Color.Color);
  SB_RGrid_Color.Color :=CD_Select_Color.Color;
  SB_RGrid_Color.Down  :=False;
  srf_var.EventGroupsCalc(calc_arr,[30]);
  SpeedButtonRepaint;
end; {$endregion}
{$endregion}

// (Snap Grid) Сетка привязки:
{LI} {$region -fold}
constructor TSGrid.Create(w,h:TColor);                                                                                                      {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  obj_var.Add(kooSGrid,srf_var.world_axis_shift);
  CreateNode('Snap Grid','');
  ObjIndsCalc;
  ScTIndsCalc;
  sgrid_dnt     :=16;
  sgrid_color   :=SetColorInv($007B6693);
  show_snap_grid:=True;
end; {$endregion}
destructor  TSGrid.Destroy;                                                                                                                 {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  inherited Destroy;
end; {$endregion}
procedure   TSGrid.SGridToBmp(constref pvt:TPtPosF; constref bmp_dst_ptr:PInteger; constref bmp_dst_width:TColor; rct_clp:TPtRect); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sht_pow_mul  : double;
  w_inc,h_inc  : double;
  i,x0,y0,x1,y1: integer;
begin
  with rct_clp do
    begin
      sht_pow_mul:=sgrid_dnt*Power(DEFAULT_SCL_MUL,srf_var.scl_dif);

      // Horizontal Lines:
      x0   :=left;
      x1   :=left+width;
      h_inc:=0;
      for i:=0 to Trunc((pvt.y-top)/sht_pow_mul) do
        begin
          y0:=Trunc(pvt.y-h_inc);
          if LineHC(x0,y0,x1,rct_clp) then
             LineH (x0,y0,x1,bmp_dst_ptr,bmp_dst_width,{clRed}sgrid_color);
          h_inc+=sht_pow_mul;
        end;
      h_inc:=sht_pow_mul;
      for i:=0 to Trunc((bottom-pvt.y)/sht_pow_mul)-1 do
        begin
          y0:=Trunc(pvt.y+h_inc);
          if LineHC(x0,y0,x1,rct_clp) then
             LineH (x0,y0,x1,bmp_dst_ptr,bmp_dst_width,{clGreen}sgrid_color);
          h_inc+=sht_pow_mul;
        end;

      // Vertical Lines:
      y0   :=top;
      y1   :=top+height;
      w_inc:=0;
      for i:=0 to Trunc((pvt.x-left)/sht_pow_mul) do
        begin
          x0:=Trunc(pvt.x-w_inc);
          if LineVC(x0,y0,y1,rct_clp) then
             LineV (x0,y0,y1,bmp_dst_ptr,bmp_dst_width,{clWhite}sgrid_color);
          w_inc+=sht_pow_mul;
        end;
      w_inc:=sht_pow_mul;
      for i:=0 to Trunc((right-pvt.x)/sht_pow_mul)-1 do
        begin
          x0:=Trunc(pvt.x+w_inc);
          if LineVC(x0,y0,y1,rct_clp) then
             LineV (x0,y0,y1,bmp_dst_ptr,bmp_dst_width,{clBlack}sgrid_color);
          w_inc+=sht_pow_mul;
        end;

    end;
end; {$endregion}
procedure   TSGrid.FilSGridObj(constref sgrid_ind:TColor);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
begin   
  with srf_var do
    if show_snap_grid then
      begin   
        obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.sgrid_inds_obj_arr[sgrid_ind]]);
        with obj_arr_ptr^ do
          SGridToBmp(PtPosF(world_axis.x+world_axis_shift.x,
                            world_axis.y+world_axis_shift.y),
                            bkgnd_ptr,
                            bkgnd_width,
                            rct_clp);
      end;
end; {$endregion}
procedure   TSGrid.AlignPts(var pts:TPtPosFArr; const sel_pts_inds:TColorArr; const pts_cnt,sel_pts_cnt:TColor);                            {$ifdef Linux}[local];{$endif} {$region -fold}
begin
end; {$endregion}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.SB_SGridClick                                (sender:TObject);                                                                                        {$region -fold}
begin
  DrawingPanelsSetVisibility1(down_sgrid_ptr,P_SGrid,P_Draw_Custom_Panel,prev_panel_draw,curr_panel_draw);
  DrawingPanelsSetVisibility2;
end; {$endregion}
procedure TF_MainForm.P_2D_Operations_AutomaticMouseEnter          (sender:TObject);                                                                                        {$region -fold}
begin
end; {$endregion}
procedure TF_MainForm.P_2D_Operations_AutomaticMouseLeave          (sender:TObject);                                                                                        {$region -fold}
begin
end; {$endregion}
procedure TF_MainForm.SE_Align_2D_Points_Precision_UMouseEnter     (sender:TObject);                                                                                        {$region -fold}
begin
end; {$endregion}
procedure TF_MainForm.SE_Align_2D_Points_Precision_VMouseEnter     (sender:TObject);                                                                                        {$region -fold}
begin
end; {$endregion}
procedure TF_MainForm.SE_Align_2D_Points_Precision_UChange         (sender:TObject);                                                                                        {$region -fold}
begin
end; {$endregion}
procedure TF_MainForm.SE_Align_2D_Points_Precision_VChange         (sender:TObject);                                                                                        {$region -fold}
begin
end; {$endregion}
procedure TF_MainForm.SE_Align_2D_Points_Precision_UMouseLeave     (sender:TObject);                                                                                        {$region -fold}
begin
end; {$endregion}
procedure TF_MainForm.SE_Align_2D_Points_Precision_VMouseLeave     (sender:TObject);                                                                                        {$region -fold}
begin
end; {$endregion}
procedure TF_MainForm.CB_Align_2D_Points_Show_Snap_GridChange      (sender:TObject);                                                                                        {$region -fold}
begin
end; {$endregion}
procedure TF_MainForm.CB_Align_2D_Points_Snap_Grid_VisibilityChange(sender:TObject);                                                                                        {$region -fold}
begin
end; {$endregion}
{$endregion}

// (UV Grid) UV сетка:
{LI} {$region -fold}
constructor TUV.Create(w,h:TColor); {$ifdef Linux}[local];{$endif} {$region -fold}
begin
end; {$endregion}
destructor TUV.Destroy;             {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  inherited Destroy;
end; {$endregion}
{$endregion}

// (Intersection Graph) Граф пересечений:
{LI} {$region -fold}
constructor TISGraph.Create(w,h:TColor); {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
destructor  TISGraph.Destroy;            {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  inherited Destroy;
end; {$endregion}
procedure TISGraph.ISGraphCalc;  inline; {$ifdef Linux}[local];{$endif} {$region -fold}
{var
  i,j: integer;
  k  : integer=0;
  v_x: double =0.0;
  v_y: double =0.0;}
begin
  {if show_is_graph then
    if (spline_obj_count>1) then
      for i:=0 to spline_obj_count-1 do
        begin
          k+=spline_obj_pts_count[i];
          for j:=k to k+spline_obj_pts_count[i+1]-1 do
            v_x+=spline_pts[j].x;
          is_graph_pts[i].x:=v_x/spline_obj_pts_count[i+1];
          v_x:=0;
          for j:=k to k+spline_obj_pts_count[i+1]-1 do
            v_y+=spline_pts[j].y;
          is_graph_pts[i].y:=v_y/spline_obj_pts_count[i+1];
          v_y:=0;
        end;}
end; {$endregion}
procedure TISGraph.ISGraphDraw;  inline; {$ifdef Linux}[local];{$endif} {$region -fold}
{var
  i: integer;}
begin
  {with main_canvas_var.main_bmp.Canvas do
    if show_is_graph then
      if (spline_obj_count>1) then
        begin
          Pen.Mode:=pmCopy;
          Pen.Color:=clYellow;
          MoveTo(Trunc(is_graph_pts[spline_obj_count-1].x),
                 Trunc(is_graph_pts[spline_obj_count-1].y));
          for i:=0 to spline_obj_count-1 do
            LineTo(Trunc(is_graph_pts[i].x),
                   Trunc(is_graph_pts[i].y));
        end;}
end; {$endregion}
{$endregion}

// (Text) Текст:
{LI} {$region -fold}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.SB_TextClick            (sender:TObject); {$region -fold}
begin
  DrawingPanelsSetVisibility1(down_text_ptr,P_Text,P_Draw_Custom_Panel,prev_panel_draw,curr_panel_draw);
  DrawingPanelsSetVisibility2;
end; {$endregion}
procedure TF_MainForm.SB_Text_Select_FontClick(sender:TObject); {$region -fold}
begin
  SB_Text_Select_Font.Down:=False;
  if (not FontDialog1.Execute) then
    Exit;
  try
    with FontDialog1,Font do
      begin
        SetTextInfo(srf_var.srf_bmp.Canvas,height,color,name,charset);
        srf_var.srf_bmp.Canvas.TextOut(10,400,'Start Demo');
      end;
  except
    on E: Exception do
      MessageDlg('Error','Error: '+E.Message,mtError,[mbOk],0);
  end;
end; {$endregion}
{$endregion}

// (Brush) Кисть:
{LI} {$region -fold}
procedure BrushDraw(x,y:integer); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  brush_area: TRect;
  i,j       : integer;
begin
  with srf_var.srf_bmp.Canvas,srf_var do
    begin
      brush_area.Left  :=X-64{-temp_bmp_rect.Left};
      brush_area.Top   :=Y-64{-temp_bmp_rect.Top};
      brush_area.Right :=X+64{-temp_bmp_rect.Left};
      brush_area.Bottom:=Y+64{-temp_bmp_rect.Top};
      case F_MainForm.CB_Brush_Mode.ItemIndex of

        0: // Brush Mode: Normal
          StretchDraw(brush_area,custom_icon);

        4: // Brush Mode: Lighting
          for i:=-F_MainForm.SE_Brush_Radius.value to F_MainForm.SE_Brush_Radius.value do
            for j:=-F_MainForm.SE_Brush_Radius.value to F_MainForm.SE_Brush_Radius.value do
              if ((2*GetRValue(Pixels[X+i,Y+j])+
                     GetGValue(Pixels[X+i,Y+j])+
                   3*GetGValue(Pixels[X+i,Y+j]))/6)+
                     F_MainForm.SE_Brush_Hardness.value>100 then
                Pixels[X+i-srf_bmp_rct.Left,Y+j-srf_bmp_rct.Top]:=RGB(GetRValue(Pixels[X+i{-temp_bmp_rect.Left},Y+j{-temp_bmp_rect.Top}])+F_MainForm.SE_Brush_Hardness.value,
                                                                      GetGValue(Pixels[X+i{-temp_bmp_rect.Left},Y+j{-temp_bmp_rect.Top}])+F_MainForm.SE_Brush_Hardness.value,
                                                                      GetGValue(Pixels[X+i{-temp_bmp_rect.Left},Y+j{-temp_bmp_rect.Top}])+F_MainForm.SE_Brush_Hardness.value);
      end;
    end;
end; {$endregion}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.SB_BrushClick(sender:TObject);                     {$region -fold}
begin
  DrawingPanelsSetVisibility1(down_brush_ptr,P_Brush,P_Draw_Custom_Panel,prev_panel_draw,curr_panel_draw);
  DrawingPanelsSetVisibility2;
end; {$endregion}
{$endregion}

// (Spray) Спрей:
{LI} {$region -fold}
procedure SprayDraw(x,y,r:integer; custom_color:TColor); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rad,a  : double;
  i,m1,m2: integer;
begin
  a  :=Random*2*pi;
  rad:=Random*r;
  m1 :=Trunc(rad*Cos(a));
  m2 :=Trunc(rad*Sin(a));
  for i:=0 to 100 do
    tex_var.loaded_picture.Bitmap.Canvas.Pixels[X+m1,Y+m2]:=custom_color;
end; {$endregion}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.SB_SprayClick(sender:TObject);                                            {$region -fold}
begin
  DrawingPanelsSetVisibility1(down_spray_ptr,P_Spray,P_Draw_Custom_Panel,prev_panel_draw,curr_panel_draw);
  DrawingPanelsSetVisibility2;
end; {$endregion}
{$endregion}

// (Spline) Сплайн:
{LI} {$region -fold}
constructor TCurve.Create          (constref w,h              :TColor;  constref bkgnd_ptr:PInteger; constref bkgnd_width,bkgnd_height:TColor);             {$ifdef Linux}[local];{$endif} {$region -fold}
begin

  //spline_saved_up_pts_var:=TSavedUpPts.Create;

  // spline edges bounding rectangles:
  rct_eds_big_img:=TFastLine.Create;
  with rct_eds_big_img do
    begin
      SplineInit(w,h,False,True,False,False);
      SetBkgnd  (bkgnd_ptr,bkgnd_width,bkgnd_height);
    end;

  // spline points bounding rectangles:
  rct_pts_big_img:=TFastLine.Create;
  with rct_pts_big_img do
    begin
      SplineInit(w,h,False,True,False,False);
      SetBkgnd  (bkgnd_ptr,bkgnd_width,bkgnd_height);
    end;

  // spline edges:
  eds_big_img:=TFastLine.Create;
  with eds_big_img do
    begin
      SplineInit(w,h,True,True,False,True);
      SetBkgnd  (bkgnd_ptr,bkgnd_width,bkgnd_height);
    end;

  // spline points:
  pts_big_img:=TFastLine.Create;
  with pts_big_img do
    begin
      SplineInit(w,h,True,True,False,True);
      SetBkgnd  (bkgnd_ptr,bkgnd_width,bkgnd_height);
    end;

  // duplicated points:
  SetLength     (dup_pts_arr,w*h);

  global_prop        :=curve_default_prop;
  has_hid_ln_elim_sln:=False;
  cur_tlt_dwn_btn_ind:=-1;
  show_spline        :=True;
  FmlSplineInit;
  SetLength(fml_pts,global_prop.cycloid_pts_cnt);

end; {$endregion}
destructor  TCurve.Destroy;                                                                                                                                 {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  inherited Destroy;
end; {$endregion}
procedure TCurve.PrimitiveComp     (constref spline_ind       :TColor;  constref pmt_var_ptr,pmt_big_var_ptr:PFastLine; pmt_bld_stl:TDrawingStyle); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with pmt_var_ptr^,fst_img do
    begin
      with rct_vis do
        SetRctPos
        (
          left,
          top
        );
      with pmt_big_var_ptr^ do
        SetValInfo
        (
          ln_arr1_ptr,
          ln_arr1_ptr,
          ln_arr1_ptr,
          ln_arr_width,
          ln_arr_height
        );
      with obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]] do
        SetBkgnd
        (
          bkgnd_ptr,
          bkgnd_width,
          bkgnd_height
        );
      bmp_src_rct_clp          :=PtRct(rct_vis);
      img_kind                 :=1{11};
      pix_drw_type             :=1; //must be in range of [0..002]
      fx_cnt                   :=1; //must be in range of [0..255]
      fx_arr[0].rep_cnt        :=1; //must be in range of [0..255]
      fx_arr[0].nt_pix_srf_type:=1; //must be in range of [0..001]
      fx_arr[0].nt_pix_cfx_type:=GetEnumVal(pmt_bld_stl);
      fx_arr[0].pt_pix_srf_type:=1; //must be in range of [0..001]
      fx_arr[0].pt_pix_cfx_type:=fx_arr[0].nt_pix_cfx_type;
    //nt_pix_clp_type          :=0;
    //nt_pix_srf_type          :=0;
      col_trans_arr[2]         :=064;
      col_trans_arr[4]         :=100;
      col_trans_arr[5]         :=100;
      //pmt_big_var_ptr^.ln_arr0_ptr:=@pmt_big_var_ptr^.ln_arr0[0];
      if local_prop.byte_mode and (not down_select_points_ptr^) then
        bmp_alpha_ptr2:=pmt_big_var_ptr^.ln_arr0_ptr
      else
        bmp_alpha_ptr2:=Nil;
      remove_brunching_none:=local_prop.remove_brunching_none;
      CmpProc[11];
      SetRctPos(bmp_src_rct_clp);
      SetSdrType;
      ShaderType;
    end;
end; {$endregion}
procedure TCurve.AddPoint          (constref x,y              :integer; constref bmp_dst_ptr:PInteger; constref bmp_dst_width:TColor; var color_info:TColorInfo; constref rct_clp:TPtRect; var add_spline_calc_:boolean; sleep_:boolean=False); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rad,a: double;
  m1   : integer=0;
  m2   : integer=0;
begin
  add_spline_calc_:=True;
  Inc(sln_pts_cnt);
  Inc(sln_pts_cnt_add);

  if (global_prop.sln_mode=smSpray) then
    begin
      a  :=Random*2*pi;
      rad:={Random*}global_prop.spray_rad;
      m1 :=Trunc(rad*Cos(a));
      m2 :=Trunc(rad*Sin(a));
    end;

  AddListItem(PtPosF(x-srf_var.world_axis_shift.x+m1,y-srf_var.world_axis_shift.y+m2),first_item,p1,p2);
  {SetLength(sln_pts_add,sln_pts_cnt_add);
  sln_pts_add[sln_pts_cnt_add-1].x:=x-srf_var.world_axis_shift.x;
  sln_pts_add[sln_pts_cnt_add-1].y:=y-srf_var.world_axis_shift.y;}

  SetColorInfo(clRed,color_info);
  Point(x+m1,y+m2,
        bmp_dst_ptr,
        bmp_dst_width,
        color_info,
        rct_clp);
  if sleep_ then
    {$ifdef Windows}
    Sleep (global_prop.sln_pts_frq);
    {$else}
    USleep(global_prop.sln_pts_frq*1000000);
    {$endif}
end; {$endregion}
procedure TCurve.RctSplineRct0     (constref spline_ind       :TColor;  var      rct_out_,rct_ent_:TRect);                                                  {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with rct_eds_img_arr[spline_ind] do
    rct_out_:=Rect
    (
      rct_out_ptr^.left,
      rct_out_ptr^.top,
      rct_out_ptr^.right,
      rct_out_ptr^.bottom
    );
end; {$endregion}
procedure TCurve.RctSplineRct1     (constref spline_ind       :TColor;  var      rct_out_,rct_ent_:TRect);                                                  {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  rct_ent_:=PtsRngRctCalc
  (
    sln_pts,
    rct_bnd_ind_arr[spline_ind],
    partial_pts_sum[spline_ind],
    partial_pts_sum[spline_ind]+sln_obj_pts_cnt[spline_ind]-1
  );
end; {$endregion}
procedure TCurve.RctSplineRct2     (constref spline_ind       :TColor;  var      rct_out_,rct_ent_:TRect);                                                  {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PtRct(sln_pts,rct_bnd_ind_arr[spline_ind],rct_ent_);
end; {$endregion}
procedure TCurve.RctSplineRctEds   (constref spline_ind       :TColor;  constref rct_out_,rct_ent_:TRect);                                                  {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with rct_eds_img_arr[spline_ind],local_prop do
    begin

      {Final   Rectangle} {$region -fold}
      rct_wnd:=eds_img_arr[spline_ind].rct_wnd; {$endregion}

      {Entire  Rectangle} {$region -fold}
      rct_ent:=eds_img_arr[spline_ind].rct_ent; {$endregion}

      {Clipped Rectangle} {$region -fold}
      rct_vis:=eds_img_arr[spline_ind].rct_vis; {$endregion}

    end;
end; {$endregion}
procedure TCurve.RctSplineRctPts   (constref spline_ind       :TColor;  constref rct_out_,rct_ent_:TRect);                                                  {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with rct_pts_img_arr[spline_ind],local_prop do
    begin

      {Final   Rectangle} {$region -fold}
      rct_wnd:=pts_img_arr[spline_ind].rct_wnd; {$endregion}

      {Entire  Rectangle} {$region -fold}
      rct_ent:=pts_img_arr[spline_ind].rct_ent; {$endregion}

      {Clipped Rectangle} {$region -fold}
      rct_vis:=pts_img_arr[spline_ind].rct_vis; {$endregion}

    end;
end; {$endregion}
procedure TCurve.RctSplineEds      (constref spline_ind       :TColor;  constref rct_out_,rct_ent_:TRect);                                                  {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
begin
  with eds_img_arr[spline_ind],local_prop do
    begin

      {Final   Rectangle} {$region -fold}
      rct_wnd:=rct_out_; {$endregion}

      {Entire  Rectangle} {$region -fold}
      with rct_ent do
        begin
          obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
          left       :=rct_ent_.left  -eds_width_half-1+eds_width_odd+obj_arr_ptr^.world_axis_shift.x;
          top        :=rct_ent_.top   -eds_width_half-1+eds_width_odd+obj_arr_ptr^.world_axis_shift.y;
          right      :=rct_ent_.right +eds_width_half+1              +obj_arr_ptr^.world_axis_shift.x;
          bottom     :=rct_ent_.bottom+eds_width_half+1              +obj_arr_ptr^.world_axis_shift.y;
          width      :=right-left;
          height     :=bottom-top;
        end; {$endregion}

      {Clipped Rectangle} {$region -fold}
      rct_vis:=ClippedRct(rct_wnd,rct_ent,False); {$endregion}

    end;
end; {$endregion}
procedure TCurve.RctSplinePts      (constref spline_ind       :TColor;  constref rct_out_,rct_ent_:TRect);                                                  {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
begin
  with pts_img_arr[spline_ind],local_prop do
    begin

      {Final   Rectangle} {$region -fold}
      rct_wnd:=rct_out_; {$endregion}

      {Entire  Rectangle} {$region -fold}
      with rct_ent do
        begin
          obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
          left       :=rct_ent_.left  -pts_rct_inn_width >>1-pts_rct_tns_left  {{?}-1{?}}+pts_rct_width__odd+obj_arr_ptr^.world_axis_shift.x;
          top        :=rct_ent_.top   -pts_rct_inn_height>>1-pts_rct_tns_top   {{?}-1{?}}+pts_rct_height_odd+obj_arr_ptr^.world_axis_shift.y;
          right      :=rct_ent_.right +pts_rct_inn_width >>1+pts_rct_tns_right {{?}+1{?}}                   +obj_arr_ptr^.world_axis_shift.x;
          bottom     :=rct_ent_.bottom+pts_rct_inn_height>>1+pts_rct_tns_bottom{{?}+1{?}}                   +obj_arr_ptr^.world_axis_shift.y;
          width      :=right-left;
          height     :=bottom-top;
        end; {$endregion}

      {Clipped Rectangle} {$region -fold}
      rct_vis:=ClippedRct(rct_wnd,rct_ent,False); {$endregion}

    end;
end; {$endregion}
procedure TCurve.RctSplineObj0     (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rct_ent_: TRect;
  rct_out_: TRect;
begin
  RctSplineRct0  (spline_ind,rct_out_,rct_ent_);
  RctSplineRct1  (spline_ind,rct_out_,rct_ent_);
  RctSplineEds   (spline_ind,rct_out_,rct_ent_);
  RctSplinePts   (spline_ind,rct_out_,rct_ent_);
  RctSplineRctEds(spline_ind,rct_out_,rct_ent_);
  RctSplineRctPts(spline_ind,rct_out_,rct_ent_);
end; {$endregion}
procedure TCurve.RctSplineObj1     (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rct_ent_: TRect;
  rct_out_: TRect;
begin
  RctSplineRct0  (spline_ind,rct_out_,rct_ent_);
  RctSplineRct2  (spline_ind,rct_out_,rct_ent_);
  RctSplineEds   (spline_ind,rct_out_,rct_ent_);
  RctSplinePts   (spline_ind,rct_out_,rct_ent_);
  RctSplineRctEds(spline_ind,rct_out_,rct_ent_);
  RctSplineRctPts(spline_ind,rct_out_,rct_ent_);
end; {$endregion}
procedure TCurve.RctSplineAll0     (constref start_ind,end_ind:TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i,j: integer;
begin
  for i:=0 to sln_obj_cnt-1 do
    begin
      j:=obj_var.obj_arr[obj_var.curve_inds_obj_arr[i]].t_ind;
      if (j>=start_ind) and (j<=end_ind) then
        RctSplineObj0(i);
    end;
end; {$endregion}
procedure TCurve.RctSplineAll1     (constref start_ind,end_ind:TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i,j: integer;
begin
  for i:=0 to sln_obj_cnt-1 do
    begin
      j:=obj_var.obj_arr[obj_var.curve_inds_obj_arr[i]].t_ind;
      if (j>=start_ind) and (j<=end_ind) then
        begin
          if (has_sel_pts[i]=0) then
            Continue;
          RctSplineObj0(i);
        end;
    end;
end; {$endregion}
procedure TCurve.RctSplineAll2     (constref start_ind,end_ind:TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i,j: integer;
begin
  for i:=0 to sln_obj_cnt-1 do
    begin
      j:=obj_var.obj_arr[obj_var.curve_inds_obj_arr[i]].t_ind;
      if (j>=start_ind) and (j<=end_ind) then
        RctSplineObj1(i);
    end;
end; {$endregion}
procedure TCurve.RctSplineAll3     (constref start_ind,end_ind:TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i,j: integer;
begin
  for i:=0 to sln_obj_cnt-1 do
    begin
      j:=obj_var.obj_arr[obj_var.curve_inds_obj_arr[i]].t_ind;
      if (j>=start_ind) and (j<=end_ind) then
        begin
          if (has_sel_pts[i]=0) then
            Continue;
          RctSplineObj1(i);
        end;
    end;
end; {$endregion}
procedure TCurve.AddSplineObj      (constref rct_out          :TPtRect);                                                                                    {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sln_pts_ptr    : PPtPosF;
  sln_pts_add_ptr: PPtPosF;
  m,i,d_cnt      : integer;
begin

  {Misc. Precalc.---------------} {$region -fold}
  Inc   (sln_obj_cnt);
  m    :=sln_obj_cnt-1;
  d_cnt:=sln_pts_cnt-sln_pts_cnt_add; {$endregion}

  {Buffers Init.----------------} {$region -fold}
  SetLength(sln_sprite_counter_pos_arr,sln_obj_cnt);
  SetLength(sln_sprite_counter_rad_arr,sln_obj_cnt);
  SetLength(sln_sprite_counter_pow_arr,sln_obj_cnt);
  Randomize;
  sln_sprite_counter_rad_arr[m]:={064}002+Random(030);
  sln_sprite_counter_pow_arr[m]:={016}200+Random(032);
  SetLength(rct_eds_img_arr    ,sln_obj_cnt);
  SetLength(rct_pts_img_arr    ,sln_obj_cnt);
  SetLength(    eds_img_arr    ,sln_obj_cnt);
  SetLength(    pts_img_arr    ,sln_obj_cnt);
  SetLength(partial_pts_sum    ,sln_obj_cnt);
  SetLength(sln_obj_pts_cnt    ,sln_obj_cnt);
  SetLength(has_sel_pts        ,sln_obj_cnt);
  SetLength(rct_bnd_ind_arr    ,sln_obj_cnt);
  SetLength(sln_pts            ,sln_pts_cnt);
  SetLength(sln_obj_ind        ,sln_pts_cnt);
  SetLength(fst_lst_sln_obj_pts,sln_pts_cnt);
  SetLength(has_edge           ,sln_pts_cnt);

  with sel_var do
    begin
      SetLength(out_or_inn_subgraph_pts,sln_pts_cnt);
      SetLength(sel_pts_inds           ,sln_pts_cnt); // Выделение памяти для массива индексов выделенных точек всех полилиний
      SetLength(is_point_selected      ,sln_pts_cnt); // Выделение памяти для массива значений "point is selected"
      SetLength(is_point_in_circle     ,sln_pts_cnt); // Выделение памяти для массива значений "point is in circle")
    end;

  if (sln_pts_cnt_add>0) then
    begin
      if (global_prop.sln_type=stFreeHand) then
        begin
          SetLength(sln_pts_add,sln_pts_cnt_add );
          ListToArr(sln_pts_add,first_item,p1,p2);
          FreeList2(            first_item,p1,p2);
        end;
      sln_pts_ptr    :=Unaligned(@sln_pts    [d_cnt]);
      sln_pts_add_ptr:=Unaligned(@sln_pts_add[00000]);
      for i:=0 to sln_pts_cnt_add-1 do
        (sln_pts_ptr+i)^:=(sln_pts_add_ptr+i)^;
      SetLength(sln_pts_add,0);
      sln_pts_cnt_add:=0;
    end;

  // spline edges bounding rectangles:
  rct_eds_img_arr[m]           :=TFastLine.Create;
  rct_eds_img_arr[m].local_prop:=global_prop;
  // spline points bounding rectangles:
  rct_pts_img_arr[m]           :=TFastLine.Create;
  rct_pts_img_arr[m].local_prop:=global_prop;
  // spline edges:
      eds_img_arr[m]           :=TFastLine.Create;
      eds_img_arr[m].local_prop:=global_prop;
  // spline points:
      pts_img_arr[m]           :=TFastLine.Create;
      pts_img_arr[m].local_prop:=global_prop; {$endregion}

  {Spline Object Calc.----------} {$region -fold}
  if (sln_obj_cnt=1) then
    begin
      partial_pts_sum[0]:=0;
      sln_obj_pts_cnt[0]:=sln_pts_cnt;
    end;
  if (sln_obj_cnt>1) then
    begin
      partial_pts_sum[m]:=partial_pts_sum[m-1]+sln_obj_pts_cnt[m-1];
      sln_obj_pts_cnt[m]:=sln_pts_cnt         -partial_pts_sum[m  ];
    end;
  if (sln_obj_pts_cnt[m]=1) then // if spline object has 1 point
    begin
      fst_lst_sln_obj_pts[partial_pts_sum[m]                     ]:=3; // set first spline object point
      fst_lst_sln_obj_pts[partial_pts_sum[m]+sln_obj_pts_cnt[m]-1]:=3; // set last  spline object point
    end;
  if (sln_obj_pts_cnt[m]>1) then // if spline object has more than 1 point
    begin
      fst_lst_sln_obj_pts[partial_pts_sum[m]                     ]:=1; // set first spline object point
      fst_lst_sln_obj_pts[partial_pts_sum[m]+sln_obj_pts_cnt[m]-1]:=2; // set last  spline object point
    end;
  if (global_prop.sln_mode=smSpray) then
    FillByte ((@has_edge[partial_pts_sum[m]])^,sln_obj_pts_cnt[m]-1,1);
  {for i:=0 to sln_obj_pts_cnt[m]-1 do
    begin
      has_edge[partial_pts_sum[m]+i]:=Random(2);
    end;}
  FillDWord((@sln_obj_ind[partial_pts_sum[m]])^,sln_obj_pts_cnt[m]  ,m);
  sln_eds_cnt:=sln_pts_cnt-sln_obj_cnt; {$endregion}

  {Aligning Points--------------} {$region -fold}
  {if snp_grd_var.align_pts then
    with sel_pts_var do
      snp_grd_var.AlignPts(sln_pts,sel_pts_inds,sln_pts_cnt,sel_pts_cnt);} {$endregion}

  {Spline Init.-----------------} {$region -fold}

  // spline edges bounding rectangles:
  with rct_eds_img_arr[m],local_prop do
    begin
      rct_out_ptr:=@rct_out;
      pts_col_inv:=SetColorInv(clRed);
    end;

  // spline points bounding rectangles:
  with rct_pts_img_arr[m],local_prop do
    begin
      rct_out_ptr:=@rct_out;
      pts_col_inv:=SetColorInv(clBlue);
    end;

  // spline edges:
  with eds_img_arr[m],local_prop do
    begin
      rct_out_ptr:=@rct_out;
      if eds_col_fall_off then
        begin
          eds_col:=Highlight(global_prop.eds_col,0,0,0,0,0,global_prop.eds_col_fall_off_inc);
          if   (global_prop.eds_col_fall_off_inc<>255) then
            Inc(global_prop.eds_col_fall_off_inc);
        end
      else
      if eds_col_rnd then
        RndSplineCol(local_prop,eds_col,eds_col_inv,eds_col_ptr,F_MainForm.SB_Spline_Edges_Color);
      eds_show   :=(eds_show) and
                   (eds_width<>0) and
                   (sln_obj_pts_cnt[m]<>1);
      cnc_ends   :=(cnc_ends) and
                   (sln_obj_pts_cnt[m]>2);
      eds_col_inv:=SetColorInv(eds_col);
      if hid_ln_elim then
        begin
          SetLength(useless_arr,sln_obj_pts_cnt[m]-1);
          has_hid_ln_elim_sln:=True;
        end;
    end;

  // spline points:
  with pts_img_arr[m],local_prop do
    begin
      rct_out_ptr:=@rct_out;
      if pts_col_fall_off then
        begin
          pts_col:=Highlight(global_prop.pts_col,0,0,0,0,0,global_prop.pts_col_fall_off_inc);
          if   (global_prop.pts_col_fall_off_inc<>255) then
            Inc(global_prop.pts_col_fall_off_inc);
        end
      else
      if pts_col_rnd then
        RndSplineCol(local_prop,pts_col,pts_col_inv,pts_col_ptr,F_MainForm.SB_Spline_Points_Color);
      pts_show   :=(pts_show) and
                   (pts_width <>0) and
                   (pts_height<>0);
      pts_col_inv:=SetColorInv(pts_col);
      SetRctDupId(local_prop);
    end; {$endregion}

  {Spline Object Rectangle Init.} {$region -fold}
  RctSplineObj0(m); {$endregion}

end; {$endregion}
procedure TCurve.AddSplineRctEds   (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with rct_eds_img_arr[spline_ind],local_prop do
    begin
      pts_rct_inn_width :=rct_ent.width -2;
      pts_rct_inn_height:=rct_ent.height-2;
      pts_rct_tns_left  :=1;
      pts_rct_tns_top   :=1;
      pts_rct_tns_right :=1;
      pts_rct_tns_bottom:=1;
      SetRctWidth (local_prop);
      SetRctHeight(local_prop);
      SetRctValues(local_prop);
      Rectangle
      (
        pts_rct_width__half-pts_rct_width__odd+rct_ent.left,
        pts_rct_height_half-pts_rct_height_odd+rct_ent.top ,
        rct_eds_big_img.ln_arr1_ptr,
        rct_eds_big_img.ln_arr_width,
        rct_eds_big_img.ln_arr_height,
        PtRct(rct_vis),
        local_prop,
        @PPFloodFillAdd
      );
    end;
end; {$endregion}
procedure TCurve.AddSplineRctPts   (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with rct_pts_img_arr[spline_ind],local_prop do
    begin
      pts_rct_inn_width :=rct_ent.width -2;
      pts_rct_inn_height:=rct_ent.height-2;
      pts_rct_tns_left  :=1;
      pts_rct_tns_top   :=1;
      pts_rct_tns_right :=1;
      pts_rct_tns_bottom:=1;
      SetRctWidth (local_prop);
      SetRctHeight(local_prop);
      SetRctValues(local_prop);
      Rectangle
      (
        pts_rct_width__half-pts_rct_width__odd+rct_ent.left,
        pts_rct_height_half-pts_rct_height_odd+rct_ent.top ,
        rct_pts_big_img.ln_arr1_ptr,
        rct_pts_big_img.ln_arr_width,
        rct_pts_big_img.ln_arr_height,
        PtRct(rct_vis),
        local_prop,
        @PPFloodFillAdd
      );
    end;
end; {$endregion}
procedure TCurve.AddSplineEds0     (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr    : PObjInfo;
  rct_out        : TPtRect;
  sln_pts_ptr    : PPtPosF;
  has_edge_ptr   : PShortInt;
  x0,y0,x1,y1,b,i: integer;
begin
  with eds_img_arr[spline_ind],local_prop do
    begin

      {Misc. Precalc.------------------------------------------------------------------} {$region -fold}
      b           :=partial_pts_sum[spline_ind];
      obj_arr_ptr :=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr :=Unaligned(@sln_pts [b]);
      has_edge_ptr:=Unaligned(@has_edge[b]);
      rct_out     :=PtRct(rct_out_ptr^.left  +0,
                          rct_out_ptr^.top   +0,
                          rct_out_ptr^.right -1,
                          rct_out_ptr^.bottom-1); {$endregion}

      case eds_width of
        1:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if cnc_ends then
              with eds_big_img do
                ClippedLine1
                (
                  Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x,
                  Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y,
                  Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x,
                  Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y,
                  rct_out,
                  Unaligned(@LinePHL  ),
                  Unaligned(@LinePHL20),
                  Unaligned(@LineSHL20)
                ); {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              begin
                with eds_big_img do
                  if (has_edge_ptr^=0{1}) then
                    ClippedLine1
                    (
                      Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x,
                      Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y,
                      Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x,
                      Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y,
                      rct_out,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL20),
                      Unaligned(@LineSHL20)
                    );
                Inc(sln_pts_ptr );
                Inc(has_edge_ptr);
              end; {$endregion}

          end;

        2:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if cnc_ends then
              with eds_big_img do
                begin
                  x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x;
                  y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y;
                  x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x;
                  y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y;
                  ClippedLine1
                  (
                    x0,
                    y0,
                    x1,
                    y1,
                    rct_out,
                    Unaligned(@LinePHL  ),
                    Unaligned(@LinePHL20),
                    Unaligned(@LineSHL20)
                  );
                  if (Abs(y1-y0)<Abs(x1-x0)) then
                    ClippedLine1
                    (
                      x0+0,
                      y0+1,
                      x1+0,
                      y1+1,
                      rct_out,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL20),
                      Unaligned(@LineSHL20)
                    )
                  else
                    ClippedLine1
                    (
                      x0+1,
                      y0+0,
                      x1+1,
                      y1+0,
                      rct_out,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL20),
                      Unaligned(@LineSHL20)
                    );
                end; {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              with eds_big_img do
                if (has_edge_ptr^=0{1}) then
                  begin
                    x0:=Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x;
                    y0:=Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y;
                    x1:=Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x;
                    y1:=Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y;
                    ClippedLine1
                    (
                      x0,
                      y0,
                      x1,
                      y1,
                      rct_out,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL20),
                      Unaligned(@LineSHL20)
                    );
                    if (Abs(y1-y0)<Abs(x1-x0)) then
                      ClippedLine1
                      (
                        x0+0,
                        y0+1,
                        x1+0,
                        y1+1,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL20),
                        Unaligned(@LineSHL20)
                      )
                    else
                      ClippedLine1
                      (
                        x0+1,
                        y0+0,
                        x1+1,
                        y1+0,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL20),
                        Unaligned(@LineSHL20)
                      );
                    Inc(sln_pts_ptr );
                    Inc(has_edge_ptr);
                  end; {$endregion}

          end;
        3:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if cnc_ends then
              with eds_big_img do
                begin
                  x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x;
                  y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y;
                  x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x;
                  y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y;
                  ClippedLine1
                  (
                    x0,
                    y0,
                    x1,
                    y1,
                    rct_out,
                    Unaligned(@LinePHL  ),
                    Unaligned(@LinePHL20),
                    Unaligned(@LineSHL20)
                  );
                  if (Abs(y1-y0)<Abs(x1-x0)) then
                    begin
                      ClippedLine1
                      (
                        x0+0,
                        y0+1,
                        x1+0,
                        y1+1,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL20),
                        Unaligned(@LineSHL20)
                      );
                      ClippedLine1
                      (
                        x0+0,
                        y0-1,
                        x1+0,
                        y1-1,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL20),
                        Unaligned(@LineSHL20)
                      );
                    end
                  else
                    begin
                      ClippedLine1
                      (
                        x0+1,
                        y0+0,
                        x1+1,
                        y1+0,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL20),
                        Unaligned(@LineSHL20)
                      );
                      ClippedLine1
                      (
                        x0-1,
                        y0+0,
                        x1-1,
                        y1+0,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL20),
                        Unaligned(@LineSHL20)
                      );
                    end;
                end; {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              with eds_big_img do
                if (has_edge_ptr^=0{1}) then
                  begin
                    x0:=Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x;
                    y0:=Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y;
                    x1:=Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x;
                    y1:=Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y;
                    ClippedLine1
                    (
                      x0,
                      y0,
                      x1,
                      y1,
                      rct_out,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL20),
                      Unaligned(@LineSHL20)
                    );
                    if (Abs(y1-y0)<Abs(x1-x0)) then
                      begin
                        ClippedLine1
                        (
                          x0+0,
                          y0+1,
                          x1+0,
                          y1+1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL20),
                          Unaligned(@LineSHL20)
                        );
                        ClippedLine1
                        (
                          x0+0,
                          y0-1,
                          x1+0,
                          y1-1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL20),
                          Unaligned(@LineSHL20)
                        );
                      end
                    else
                      begin
                        ClippedLine1
                        (
                          x0+1,
                          y0+0,
                          x1+1,
                          y1+0,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL20),
                          Unaligned(@LineSHL20)
                        );
                        ClippedLine1
                        (
                          x0-1,
                          y0+0,
                          x1-1,
                          y1+0,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL20),
                          Unaligned(@LineSHL20)
                        );
                      end;
                    Inc(sln_pts_ptr );
                    Inc(has_edge_ptr);
                  end; {$endregion}

          end;
      end;

    end;
end; {$endregion}
procedure TCurve.AddSplineEds1     (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr    : PObjInfo;
  rct_out        : TPtRect;
  sln_pts_ptr    : PPtPosF;
  has_edge_ptr   : PShortInt;
  x0,y0,x1,y1,b,i: integer;
begin
  with eds_img_arr[spline_ind],local_prop do
    begin

      {Misc. Precalc.------------------------------------------------------------------} {$region -fold}
      b           :=partial_pts_sum[spline_ind];
      obj_arr_ptr :=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr :=Unaligned(@sln_pts [b]);
      has_edge_ptr:=Unaligned(@has_edge[b]);
      rct_out     :=PtRct(rct_out_ptr^.left  +0,
                          rct_out_ptr^.top   +0,
                          rct_out_ptr^.right -1,
                          rct_out_ptr^.bottom-1); {$endregion}

      case eds_width of
        1:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if (not (sel_var.is_point_selected[b+00000000000000000000000000000] or
                     sel_var.is_point_selected[b+sln_obj_pts_cnt[spline_ind]-1])) then
              if cnc_ends then
                with eds_big_img do
                  ClippedLine1
                  (
                    Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x,
                    Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y,
                    Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x,
                    Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y,
                    rct_out,
                    Unaligned(@LinePHL  ),
                    Unaligned(@LinePHL20),
                    Unaligned(@LineSHL20)
                  ); {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              begin
                if (not (sel_var.is_point_selected[b+i] or
                         sel_var.is_point_selected[b+i+1])) then
                  with eds_big_img do
                    if (has_edge_ptr^=0{1}) then
                      ClippedLine1
                      (
                        Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x,
                        Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y,
                        Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x,
                        Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL20),
                        Unaligned(@LineSHL20)
                      );
                Inc(sln_pts_ptr );
                Inc(has_edge_ptr);
              end; {$endregion}

          end;

        2:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if (not (sel_var.is_point_selected[b+00000000000000000000000000000] or
                     sel_var.is_point_selected[b+sln_obj_pts_cnt[spline_ind]-1])) then
              if cnc_ends then
                with eds_big_img do
                  begin
                    x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x;
                    y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y;
                    x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x;
                    y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y;
                    ClippedLine1
                    (
                      x0,
                      y0,
                      x1,
                      y1,
                      rct_out,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL20),
                      Unaligned(@LineSHL20)
                    );
                    if (Abs(y1-y0)<Abs(x1-x0)) then
                      ClippedLine1
                      (
                        x0+0,
                        y0+1,
                        x1+0,
                        y1+1,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL20),
                        Unaligned(@LineSHL20)
                      )
                    else
                      ClippedLine1
                      (
                        x0+1,
                        y0+0,
                        x1+1,
                        y1+0,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL20),
                        Unaligned(@LineSHL20)
                      );
                  end; {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              begin
                if (not (sel_var.is_point_selected[b+i] or
                         sel_var.is_point_selected[b+i+1])) then
                  with eds_big_img do
                    if (has_edge_ptr^=0{1}) then
                      begin
                        x0:=Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y0:=Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        x1:=Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y1:=Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        ClippedLine1
                        (
                          x0,
                          y0,
                          x1,
                          y1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL20),
                          Unaligned(@LineSHL20)
                        );
                        if (Abs(y1-y0)<Abs(x1-x0)) then
                          ClippedLine1
                          (
                            x0+0,
                            y0+1,
                            x1+0,
                            y1+1,
                            rct_out,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL20),
                            Unaligned(@LineSHL20)
                          )
                        else
                          ClippedLine1
                          (
                            x0+1,
                            y0+0,
                            x1+1,
                            y1+0,
                            rct_out,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL20),
                            Unaligned(@LineSHL20)
                          );
                      end;
                  Inc(sln_pts_ptr);
                  Inc(has_edge_ptr);
              end; {$endregion}

          end;
        3:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if (not (sel_var.is_point_selected[b+00000000000000000000000000000] or
                     sel_var.is_point_selected[b+sln_obj_pts_cnt[spline_ind]-1])) then
              if cnc_ends then
                with eds_big_img do
                  begin
                    x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x;
                    y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y;
                    x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x;
                    y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y;
                    ClippedLine1
                    (
                      x0,
                      y0,
                      x1,
                      y1,
                      rct_out,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL20),
                      Unaligned(@LineSHL20)
                    );
                    if (Abs(y1-y0)<Abs(x1-x0)) then
                      begin
                        ClippedLine1
                        (
                          x0+0,
                          y0+1,
                          x1+0,
                          y1+1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL20),
                          Unaligned(@LineSHL20)
                        );
                        ClippedLine1
                        (
                          x0+0,
                          y0-1,
                          x1+0,
                          y1-1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL20),
                          Unaligned(@LineSHL20)
                        );
                      end
                    else
                      begin
                        ClippedLine1
                        (
                          x0+1,
                          y0+0,
                          x1+1,
                          y1+0,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL20),
                          Unaligned(@LineSHL20)
                        );
                        ClippedLine1
                        (
                          x0-1,
                          y0+0,
                          x1-1,
                          y1+0,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL20),
                          Unaligned(@LineSHL20)
                        );
                      end;
                  end; {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              begin
                if (not (sel_var.is_point_selected[b+i] or
                         sel_var.is_point_selected[b+i+1])) then
                  with eds_big_img do
                    if (has_edge_ptr^=0{1}) then
                      begin
                        x0:=Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y0:=Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        x1:=Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y1:=Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        ClippedLine1
                        (
                          x0,
                          y0,
                          x1,
                          y1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL20),
                          Unaligned(@LineSHL20)
                        );
                        if (Abs(y1-y0)<Abs(x1-x0)) then
                          begin
                            ClippedLine1
                            (
                              x0+0,
                              y0+1,
                              x1+0,
                              y1+1,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL20),
                              Unaligned(@LineSHL20)
                            );
                            ClippedLine1
                            (
                              x0+0,
                              y0-1,
                              x1+0,
                              y1-1,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL20),
                              Unaligned(@LineSHL20)
                            );
                          end
                        else
                          begin
                            ClippedLine1
                            (
                              x0+1,
                              y0+0,
                              x1+1,
                              y1+0,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL20),
                              Unaligned(@LineSHL20)
                            );
                            ClippedLine1
                            (
                              x0-1,
                              y0+0,
                              x1-1,
                              y1+0,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL20),
                              Unaligned(@LineSHL20)
                            );
                          end;
                      end;
                Inc(sln_pts_ptr );
                Inc(has_edge_ptr);
              end; {$endregion}

          end;
      end;

    end;
end; {$endregion}
procedure TCurve.AddSplineEds2     (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr    : PObjInfo;
  rct_out        : TPtRect;
  sln_pts_ptr    : PPtPosF;
  has_edge_ptr   : PShortInt;
  x0,y0,x1,y1,b,i: integer;
begin
  with eds_img_arr[spline_ind],local_prop do
    begin

      {Misc. Precalc.------------------------------------------------------------------} {$region -fold}
      b           :=partial_pts_sum[spline_ind];
      obj_arr_ptr :=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr :=Unaligned(@sln_pts [b]);
      has_edge_ptr:=Unaligned(@has_edge[b]);
      rct_out     :=PtRct(rct_out_ptr^.left  +0,
                          rct_out_ptr^.top   +0,
                          rct_out_ptr^.right -1,
                          rct_out_ptr^.bottom-1); {$endregion}

      case eds_width of
        1:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if sel_var.is_point_selected[b+00000000000000000000000000000] or
               sel_var.is_point_selected[b+sln_obj_pts_cnt[spline_ind]-1] then
              if cnc_ends then
                with eds_big_img do
                  ClippedLine1
                  (
                    Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x,
                    Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y,
                    Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x,
                    Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y,
                    rct_out,
                    Unaligned(@LinePHL  ),
                    Unaligned(@LinePHL20),
                    Unaligned(@LineSHL20)
                  ); {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              begin
                if sel_var.is_point_selected[b+i+0] or
                   sel_var.is_point_selected[b+i+1] then
                  with eds_big_img do
                    if (has_edge_ptr^=0{1}) then
                      ClippedLine1
                      (
                        Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x,
                        Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y,
                        Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x,
                        Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL20),
                        Unaligned(@LineSHL20)
                      );
                Inc(sln_pts_ptr );
                Inc(has_edge_ptr);
              end; {$endregion}

          end;

        2:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if sel_var.is_point_selected[b+00000000000000000000000000000] or
               sel_var.is_point_selected[b+sln_obj_pts_cnt[spline_ind]-1] then
              if cnc_ends then
                with eds_big_img do
                  begin
                    x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x;
                    y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y;
                    x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x;
                    y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y;
                    ClippedLine1
                    (
                      x0,
                      y0,
                      x1,
                      y1,
                      rct_out,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL20),
                      Unaligned(@LineSHL20)
                    );
                    if (Abs(y1-y0)<Abs(x1-x0)) then
                      ClippedLine1
                      (
                        x0+0,
                        y0+1,
                        x1+0,
                        y1+1,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL20),
                        Unaligned(@LineSHL20)
                      )
                    else
                      ClippedLine1
                      (
                        x0+1,
                        y0+0,
                        x1+1,
                        y1+0,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL20),
                        Unaligned(@LineSHL20)
                      );
                  end; {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              begin
                if sel_var.is_point_selected[b+i+0] or
                   sel_var.is_point_selected[b+i+1] then
                  with eds_big_img do
                    if (has_edge_ptr^=0{1}) then
                      begin
                        x0:=Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y0:=Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        x1:=Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y1:=Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        ClippedLine1
                        (
                          x0,
                          y0,
                          x1,
                          y1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL20),
                          Unaligned(@LineSHL20)
                        );
                        if (Abs(y1-y0)<Abs(x1-x0)) then
                          ClippedLine1
                          (
                            x0+0,
                            y0+1,
                            x1+0,
                            y1+1,
                            rct_out,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL20),
                            Unaligned(@LineSHL20)
                          )
                        else
                          ClippedLine1
                          (
                            x0+1,
                            y0+0,
                            x1+1,
                            y1+0,
                            rct_out,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL20),
                            Unaligned(@LineSHL20)
                          );
                      end;
                  Inc(sln_pts_ptr );
                  Inc(has_edge_ptr);
              end; {$endregion}

          end;
        3:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if sel_var.is_point_selected[b+00000000000000000000000000000] or
               sel_var.is_point_selected[b+sln_obj_pts_cnt[spline_ind]-1] then
              if cnc_ends then
                with eds_big_img do
                  begin
                    x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x;
                    y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y;
                    x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x;
                    y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y;
                    ClippedLine1
                    (
                      x0,
                      y0,
                      x1,
                      y1,
                      rct_out,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL20),
                      Unaligned(@LineSHL20)
                    );
                    if (Abs(y1-y0)<Abs(x1-x0)) then
                      begin
                        ClippedLine1
                        (
                          x0+0,
                          y0+1,
                          x1+0,
                          y1+1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL20),
                          Unaligned(@LineSHL20)
                        );
                        ClippedLine1
                        (
                          x0+0,
                          y0-1,
                          x1+0,
                          y1-1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL20),
                          Unaligned(@LineSHL20)
                        );
                      end
                    else
                      begin
                        ClippedLine1
                        (
                          x0+1,
                          y0+0,
                          x1+1,
                          y1+0,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL20),
                          Unaligned(@LineSHL20)
                        );
                        ClippedLine1
                        (
                          x0-1,
                          y0+0,
                          x1-1,
                          y1+0,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL20),
                          Unaligned(@LineSHL20)
                        );
                      end;
                  end; {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              begin
                if sel_var.is_point_selected[b+i+0] or
                   sel_var.is_point_selected[b+i+1] then
                  with eds_big_img do
                    if (has_edge_ptr^=0{1}) then
                      begin
                        x0:=Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y0:=Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        x1:=Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y1:=Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        ClippedLine1
                        (
                          x0,
                          y0,
                          x1,
                          y1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL20),
                          Unaligned(@LineSHL20)
                        );
                        if (Abs(y1-y0)<Abs(x1-x0)) then
                          begin
                            ClippedLine1
                            (
                              x0+0,
                              y0+1,
                              x1+0,
                              y1+1,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL20),
                              Unaligned(@LineSHL20)
                            );
                            ClippedLine1
                            (
                              x0+0,
                              y0-1,
                              x1+0,
                              y1-1,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL20),
                              Unaligned(@LineSHL20)
                            );
                          end
                        else
                          begin
                            ClippedLine1
                            (
                              x0+1,
                              y0+0,
                              x1+1,
                              y1+0,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL20),
                              Unaligned(@LineSHL20)
                            );
                            ClippedLine1
                            (
                              x0-1,
                              y0+0,
                              x1-1,
                              y1+0,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL20),
                              Unaligned(@LineSHL20)
                            );
                          end;
                      end;
                Inc(sln_pts_ptr );
                Inc(has_edge_ptr);
              end; {$endregion}

          end;
      end;

    end;
end; {$endregion}
procedure TCurve.AddSplineEds3     (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr    : PObjInfo;
  rct_out        : TPtRect;
  sln_pts_ptr    : PPtPosF;
  has_edge_ptr   : PShortInt;
  x0,y0,x1,y1,b,i: integer;
begin
  with eds_img_arr[spline_ind],local_prop do
    begin

      {Misc. Precalc.------------------------------------------------------------------} {$region -fold}
      b           :=partial_pts_sum[spline_ind];
      obj_arr_ptr :=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr :=Unaligned(@sln_pts [b]);
      has_edge_ptr:=Unaligned(@has_edge[b]);
      rct_out     :=PtRct(rct_out_ptr^.left  +0,
                          rct_out_ptr^.top   +0,
                          rct_out_ptr^.right -1,
                          rct_out_ptr^.bottom-1); {$endregion}

      case eds_width of
        1:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if sel_var.is_point_selected[b+00000000000000000000000000000] or
               sel_var.is_point_selected[b+sln_obj_pts_cnt[spline_ind]-1] then
              if cnc_ends then
                with eds_big_img do
                  ClippedLine1
                  (
                    Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x,
                    Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y,
                    Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x,
                    Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y,
                    rct_out,
                    Unaligned(@LinePHL  ),
                    Unaligned(@LinePHL10),
                    Unaligned(@LineSHL10)
                  ); {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              begin
                if sel_var.is_point_selected[b+i+0] or
                   sel_var.is_point_selected[b+i+1] then
                  with eds_big_img do
                    if (has_edge_ptr^=0{1}) then
                      ClippedLine1
                      (
                        Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x,
                        Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y,
                        Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x,
                        Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL10),
                        Unaligned(@LineSHL10)
                      );
                Inc(sln_pts_ptr );
                Inc(has_edge_ptr);
              end; {$endregion}

          end;

        2:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if sel_var.is_point_selected[b+00000000000000000000000000000] or
               sel_var.is_point_selected[b+sln_obj_pts_cnt[spline_ind]-1] then
              if cnc_ends then
                with eds_big_img do
                  begin
                    x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x;
                    y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y;
                    x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x;
                    y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y;
                    ClippedLine1
                    (
                      x0,
                      y0,
                      x1,
                      y1,
                      rct_out,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL10),
                      Unaligned(@LineSHL10)
                    );
                    if (Abs(y1-y0)<Abs(x1-x0)) then
                      ClippedLine1
                      (
                        x0+0,
                        y0+1,
                        x1+0,
                        y1+1,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL10),
                        Unaligned(@LineSHL10)
                      )
                    else
                      ClippedLine1
                      (
                        x0+1,
                        y0+0,
                        x1+1,
                        y1+0,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL10),
                        Unaligned(@LineSHL10)
                      );
                  end; {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              begin
                if sel_var.is_point_selected[b+i+0] or
                   sel_var.is_point_selected[b+i+1] then
                  with eds_big_img do
                    if (has_edge_ptr^=0{1}) then
                      begin
                        x0:=Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y0:=Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        x1:=Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y1:=Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        ClippedLine1
                        (
                          x0,
                          y0,
                          x1,
                          y1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL10),
                          Unaligned(@LineSHL10)
                        );
                        if (Abs(y1-y0)<Abs(x1-x0)) then
                          ClippedLine1
                          (
                            x0+0,
                            y0+1,
                            x1+0,
                            y1+1,
                            rct_out,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL10),
                            Unaligned(@LineSHL10)
                          )
                        else
                          ClippedLine1
                          (
                            x0+1,
                            y0+0,
                            x1+1,
                            y1+0,
                            rct_out,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL10),
                            Unaligned(@LineSHL10)
                          );
                      end;
                  Inc(sln_pts_ptr );
                  Inc(has_edge_ptr);
              end; {$endregion}

          end;
        3:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if sel_var.is_point_selected[b+00000000000000000000000000000] or
               sel_var.is_point_selected[b+sln_obj_pts_cnt[spline_ind]-1] then
              if cnc_ends then
                with eds_big_img do
                  begin
                    x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x;
                    y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y;
                    x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x;
                    y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y;
                    ClippedLine1
                    (
                      x0,
                      y0,
                      x1,
                      y1,
                      rct_out,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL10),
                      Unaligned(@LineSHL10)
                    );
                    if (Abs(y1-y0)<Abs(x1-x0)) then
                      begin
                        ClippedLine1
                        (
                          x0+0,
                          y0+1,
                          x1+0,
                          y1+1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL10),
                          Unaligned(@LineSHL10)
                        );
                        ClippedLine1
                        (
                          x0+0,
                          y0-1,
                          x1+0,
                          y1-1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL10),
                          Unaligned(@LineSHL10)
                        );
                      end
                    else
                      begin
                        ClippedLine1
                        (
                          x0+1,
                          y0+0,
                          x1+1,
                          y1+0,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL10),
                          Unaligned(@LineSHL10)
                        );
                        ClippedLine1
                        (
                          x0-1,
                          y0+0,
                          x1-1,
                          y1+0,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL10),
                          Unaligned(@LineSHL10)
                        );
                      end;
                  end; {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              begin
                if sel_var.is_point_selected[b+i+0] or
                   sel_var.is_point_selected[b+i+1] then
                  with eds_big_img do
                    if (has_edge_ptr^=0{1}) then
                      begin
                        x0:=Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y0:=Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        x1:=Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y1:=Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        ClippedLine1
                        (
                          x0,
                          y0,
                          x1,
                          y1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL10),
                          Unaligned(@LineSHL10)
                        );
                        if (Abs(y1-y0)<Abs(x1-x0)) then
                          begin
                            ClippedLine1
                            (
                              x0+0,
                              y0+1,
                              x1+0,
                              y1+1,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL10),
                              Unaligned(@LineSHL10)
                            );
                            ClippedLine1
                            (
                              x0+0,
                              y0-1,
                              x1+0,
                              y1-1,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL10),
                              Unaligned(@LineSHL10)
                            );
                          end
                        else
                          begin
                            ClippedLine1
                            (
                              x0+1,
                              y0+0,
                              x1+1,
                              y1+0,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL10),
                              Unaligned(@LineSHL10)
                            );
                            ClippedLine1
                            (
                              x0-1,
                              y0+0,
                              x1-1,
                              y1+0,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL10),
                              Unaligned(@LineSHL10)
                            );
                          end;
                      end;
                Inc(sln_pts_ptr );
                Inc(has_edge_ptr);
              end; {$endregion}

          end;
      end;

    end;
end; {$endregion}
procedure TCurve.AddSplineEds4     (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr    : PObjInfo;
  rct_out        : TPtRect;
  sln_pts_ptr    : PPtPosF;
  has_edge_ptr   : PShortInt;
  useless_arr_ptr: PByte;
  x0,y0,x1,y1,b,i: integer;
begin
  with eds_img_arr[spline_ind],local_prop do
    begin

      {Misc. Precalc.------------------------------------------------------------------} {$region -fold}
      hid_ln_cnt     :=0;
      b              :=partial_pts_sum[spline_ind];
      obj_arr_ptr    :=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr    :=Unaligned(@sln_pts    [b]);
      has_edge_ptr   :=Unaligned(@has_edge   [b]);
      useless_arr_ptr:=Unaligned(@useless_arr[0]);
      rct_out        :=PtRct(rct_out_ptr^.left  +0,
                             rct_out_ptr^.top   +0,
                             rct_out_ptr^.right -1,
                             rct_out_ptr^.bottom-1); {$endregion}

      case eds_width of
        1:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if cnc_ends then
              with eds_big_img do
                ClippedLine1
                (
                  Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x,
                  Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y,
                  Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x,
                  Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y,
                  rct_out,
                  Unaligned(@LinePHL  ),
                  Unaligned(@LinePHL20),
                  Unaligned(@LineSHL20)
                ); {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              with eds_big_img do
                begin
                  if (useless_arr_ptr^=1) then
                    if (has_edge_ptr^=0{1}) then
                      begin
                        ClippedLine1
                        (
                          Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x,
                          Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y,
                          Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x,
                          Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL20),
                          Unaligned(@LineSHL20)
                        );
                        Inc(hid_ln_cnt);
                      end;
                  Inc(sln_pts_ptr    );
                  Inc(has_edge_ptr   );
                  Inc(useless_arr_ptr);
                end; {$endregion}

          end;

        2:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if cnc_ends then
              with eds_big_img do
                begin
                  x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x;
                  y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y;
                  x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x;
                  y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y;
                  ClippedLine1
                  (
                    x0,
                    y0,
                    x1,
                    y1,
                    rct_out,
                    Unaligned(@LinePHL  ),
                    Unaligned(@LinePHL20),
                    Unaligned(@LineSHL20)
                  );
                  if (Abs(y1-y0)<Abs(x1-x0)) then
                    ClippedLine1
                    (
                      x0+0,
                      y0+1,
                      x1+0,
                      y1+1,
                      rct_out,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL20),
                      Unaligned(@LineSHL20)
                    )
                  else
                    ClippedLine1
                    (
                      x0+1,
                      y0+0,
                      x1+1,
                      y1+0,
                      rct_out,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL20),
                      Unaligned(@LineSHL20)
                    );
                end; {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              with eds_big_img do
                begin
                  if (useless_arr_ptr^=1) then
                    if (has_edge_ptr^=0{1}) then
                      begin
                        x0:=Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y0:=Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        x1:=Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y1:=Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        ClippedLine1
                        (
                          x0,
                          y0,
                          x1,
                          y1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL20),
                          Unaligned(@LineSHL20)
                        );
                        if (Abs(y1-y0)<Abs(x1-x0)) then
                          ClippedLine1
                          (
                            x0+0,
                            y0+1,
                            x1+0,
                            y1+1,
                            rct_out,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL20),
                            Unaligned(@LineSHL20)
                          )
                        else
                          ClippedLine1
                          (
                            x0+1,
                            y0+0,
                            x1+1,
                            y1+0,
                            rct_out,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL20),
                            Unaligned(@LineSHL20)
                          );
                        Inc(hid_ln_cnt);
                      end;
                  Inc(sln_pts_ptr    );
                  Inc(has_edge_ptr   );
                  Inc(useless_arr_ptr);
                end; {$endregion}

          end;
        3:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if cnc_ends then
              with eds_big_img do
                begin
                  x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x;
                  y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y;
                  x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x;
                  y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y;
                  ClippedLine1
                  (
                    x0,
                    y0,
                    x1,
                    y1,
                    rct_out,
                    Unaligned(@LinePHL  ),
                    Unaligned(@LinePHL20),
                    Unaligned(@LineSHL20)
                  );
                  if (Abs(y1-y0)<Abs(x1-x0)) then
                    begin
                      ClippedLine1
                      (
                        x0+0,
                        y0+1,
                        x1+0,
                        y1+1,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL20),
                        Unaligned(@LineSHL20)
                      );
                      ClippedLine1
                      (
                        x0+0,
                        y0-1,
                        x1+0,
                        y1-1,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL20),
                        Unaligned(@LineSHL20)
                      );
                    end
                  else
                    begin
                      ClippedLine1
                      (
                        x0+1,
                        y0+0,
                        x1+1,
                        y1+0,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL20),
                        Unaligned(@LineSHL20)
                      );
                      ClippedLine1
                      (
                        x0-1,
                        y0+0,
                        x1-1,
                        y1+0,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL20),
                        Unaligned(@LineSHL20)
                      );
                    end;
                end; {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              with eds_big_img do
                begin
                  if (useless_arr_ptr^=1) then
                    if (has_edge_ptr^=0{1}) then
                      begin
                        x0:=Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y0:=Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        x1:=Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y1:=Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        ClippedLine1
                        (
                          x0,
                          y0,
                          x1,
                          y1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL20),
                          Unaligned(@LineSHL20)
                        );
                        if (Abs(y1-y0)<Abs(x1-x0)) then
                          begin
                            ClippedLine1
                            (
                              x0+0,
                              y0+1,
                              x1+0,
                              y1+1,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL20),
                              Unaligned(@LineSHL20)
                            );
                            ClippedLine1
                            (
                              x0+0,
                              y0-1,
                              x1+0,
                              y1-1,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL20),
                              Unaligned(@LineSHL20)
                            );
                          end
                        else
                          begin
                            ClippedLine1
                            (
                              x0+1,
                              y0+0,
                              x1+1,
                              y1+0,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL20),
                              Unaligned(@LineSHL20)
                            );
                            ClippedLine1
                            (
                              x0-1,
                              y0+0,
                              x1-1,
                              y1+0,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL20),
                              Unaligned(@LineSHL20)
                            );
                          end;
                        Inc(hid_ln_cnt);
                      end;
                  Inc(sln_pts_ptr    );
                  Inc(has_edge_ptr   );
                  Inc(useless_arr_ptr);
                end; {$endregion}

          end;
      end;

      {Count Of Hidden Lines} {$region -fold}
      hid_ln_cnt:=eds_big_img.hid_ln_cnt; {$endregion}

    end;
end; {$endregion}
procedure TCurve.AddSplineEds5     (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr    : PObjInfo;
  rct_out        : TPtRect;
  sln_pts_ptr    : PPtPosF;
  has_edge_ptr   : PShortInt;
  pt_shift       : TPtPos;
  pt             : double;
  pt2            : TPtPosF;
  bmp_dst_ptr2   : PInteger;
  x0,y0,x1,y1,b,i: integer;
  eds_col_inv2   : integer;
begin
  with eds_img_arr[spline_ind],local_prop do
    begin

      {Misc. Precalc.-----------------------------------------} {$region -fold}
      b           :=partial_pts_sum[spline_ind];
      obj_arr_ptr :=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr :=Unaligned(@sln_pts [b]);
      has_edge_ptr:=Unaligned(@has_edge[b]);
      rct_out     :=PtRct(rct_out_ptr^.left,
                          rct_out_ptr^.top ,
                          rct_out_ptr^.right -1,
                          rct_out_ptr^.bottom-1); {$endregion}

      {Save Points Shift--------------------------------------} {$region -fold}
      pt_shift:=PtPos(rct_ent.left-rct_out_ptr^.left,rct_ent.top-rct_out_ptr^.top); {$endregion}

      {Move Spline to Left-Top Point of Inner Window Rectangle} {$region -fold}
      PtsMov(pt_shift,sln_pts,sln_obj_pts_cnt[spline_ind],partial_pts_sum[spline_ind]);
      PtsMov(pt_shift,rct_ent); {$endregion}

      {Fit Spline to Inner Window Rectangle-------------------} {$region -fold}
      if (rct_ent.height/rct_ent.width>=rct_out_ptr^.height/rct_out_ptr^.width) then
        pt:=rct_ent.height/rct_out_ptr^.height
      else
        pt:=rct_ent.width /rct_out_ptr^.width;
      PtsScl
      (
        PtPosF(rct_ent.left-obj_arr_ptr^.world_axis_shift.x,
               rct_ent.top -obj_arr_ptr^.world_axis_shift.y),
        sln_pts,
        sln_obj_pts_cnt[spline_ind],
        PtPosF(pt,pt),
        sdDown,
        b
      );
      pt2.x:=rct_ent.left-obj_arr_ptr^.world_axis_shift.x;
      pt2.y:=rct_ent.top -obj_arr_ptr^.world_axis_shift.y;
      PtsScl
      (
        PtPosF(rct_ent.left-obj_arr_ptr^.world_axis_shift.x,
               rct_ent.top -obj_arr_ptr^.world_axis_shift.y),
        rct_ent,
        PtPosF(pt,pt),
        sdDown
      );
      rct_vis:=ClippedRct(rct_out_ptr^,rct_ent,False); {$endregion}

      {Save and Set Destination Surface Handle----------------} {$region -fold}
      bmp_dst_ptr2           :=eds_big_img.bmp_dst_ptr;
      eds_big_img.bmp_dst_ptr:=@eds_useless_fld_arr[0]; {$endregion}

      {Save and Set Color(inverted value)---------------------} {$region -fold}
      eds_col_inv2                      :=eds_big_img.local_prop.eds_col_inv;
      eds_big_img.local_prop.eds_col_inv:=1; {$endregion}

      case eds_width of
        1:
          begin

            {Drawing Of Spline Object Edges-------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              with eds_big_img do
                begin
                  if (has_edge_ptr^=0{1}) then
                    ClippedLine1
                    (
                      Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x,
                      Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y,
                      Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x,
                      Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y,
                      rct_out,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL30),
                      Unaligned(@LineSHL30)
                    );
                  Inc(sln_pts_ptr           );
                  Inc(has_edge_ptr          );
                  Inc(local_prop.eds_col_inv);
                end; {$endregion}

          end;

        2:
          begin

            {Drawing Of Spline Object Edges-------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              with eds_big_img do
                begin
                  if (has_edge_ptr^=0{1}) then
                    begin
                      x0:=Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x;
                      y0:=Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y;
                      x1:=Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x;
                      y1:=Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y;
                      ClippedLine1
                      (
                        x0,
                        y0,
                        x1,
                        y1,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL30),
                        Unaligned(@LineSHL30)
                      );
                      if (Abs(y1-y0)<Abs(x1-x0)) then
                        ClippedLine1
                        (
                          x0+0,
                          y0+1,
                          x1+0,
                          y1+1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        )
                      else
                        ClippedLine1
                        (
                          x0+1,
                          y0+0,
                          x1+1,
                          y1+0,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        );
                    end;
                  Inc(sln_pts_ptr           );
                  Inc(has_edge_ptr          );
                  Inc(local_prop.eds_col_inv);
                end; {$endregion}

          end;
        3:
          begin

            {Drawing Of Spline Object Edges-------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              with eds_big_img do
                begin
                  if (has_edge_ptr^=0{1}) then
                    begin
                      x0:=Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x;
                      y0:=Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y;
                      x1:=Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x;
                      y1:=Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y;
                      ClippedLine1
                      (
                        x0,
                        y0,
                        x1,
                        y1,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL30),
                        Unaligned(@LineSHL30)
                      );
                      if (Abs(y1-y0)<Abs(x1-x0)) then
                        begin
                          ClippedLine1
                          (
                            x0+0,
                            y0+1,
                            x1+0,
                            y1+1,
                            rct_out,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL30),
                            Unaligned(@LineSHL30)
                          );
                          ClippedLine1
                          (
                            x0+0,
                            y0-1,
                            x1+0,
                            y1-1,
                            rct_out,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL30),
                            Unaligned(@LineSHL30)
                          );
                        end
                      else
                        begin
                          ClippedLine1
                          (
                            x0+1,
                            y0+0,
                            x1+1,
                            y1+0,
                            rct_out,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL30),
                            Unaligned(@LineSHL30)
                          );
                          ClippedLine1
                          (
                            x0-1,
                            y0+0,
                            x1-1,
                            y1+0,
                            rct_out,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL30),
                            Unaligned(@LineSHL30)
                          );
                        end;
                    end;
                  Inc(sln_pts_ptr           );
                  Inc(has_edge_ptr          );
                  Inc(local_prop.eds_col_inv);
                end; {$endregion}

          end;
      end;

      {Reset Spline Size--------------------------------------} {$region -fold}
      PtsScl
      (
        pt2,
        sln_pts,
        sln_obj_pts_cnt[spline_ind],
        PtPosF(pt,pt),
        sdUp,
        b
      ); {$endregion}

      {Reset Spline Position----------------------------------} {$region -fold}
      PtsMov(PtPos(-pt_shift.x,-pt_shift.y),sln_pts,sln_obj_pts_cnt[spline_ind],partial_pts_sum[spline_ind]); {$endregion}

      {Recalc. Spline Bounding Rectangles(All!)---------------} {$region -fold}
      RctSplineObj1(spline_ind){RctSplineObj0(spline_ind)}; {$endregion}

      {Reset Destination Surface Handle-----------------------} {$region -fold}
      eds_big_img.bmp_dst_ptr:=bmp_dst_ptr2; {$endregion}

      {Reset Color(inverted value)----------------------------} {$region -fold}
      eds_big_img.local_prop.eds_col_inv:=eds_col_inv2; {$endregion}

    end;
end; {$endregion}
procedure TCurve.AddSplineEds6     (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr    : PObjInfo;
  rct_out        : TPtRect;
  sln_pts_ptr    : PPtPosF;
  has_edge_ptr   : PShortInt;
  x0,y0,x1,y1,b,i: integer;
begin
  with eds_img_arr[spline_ind],local_prop do
    begin

      {Misc. Precalc.------------------------------------------------------------------} {$region -fold}
      b           :=partial_pts_sum[spline_ind];
      obj_arr_ptr :=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr :=Unaligned(@sln_pts [b]);
      has_edge_ptr:=Unaligned(@has_edge[b]);
      rct_out     :=PtRct(rct_out_ptr^.left  +0,
                          rct_out_ptr^.top   +0,
                          rct_out_ptr^.right -1,
                          rct_out_ptr^.bottom-1); {$endregion}

      case eds_width of
        1:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if cnc_ends then
              with eds_big_img do
                ClippedLine1
                (
                  Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x,
                  Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y,
                  Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x,
                  Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y,
                  rct_out,
                  Unaligned(@LinePHL  ),
                  Unaligned(@LinePHL02),
                  Unaligned(@LineSHL00)
                ); {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              begin
                with eds_big_img do
                  if (has_edge_ptr^=0{1}) then
                    ClippedLine1
                    (
                      Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x,
                      Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y,
                      Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x,
                      Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y,
                      rct_out,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL02),
                      Unaligned(@LineSHL00)
                    );
                Inc(sln_pts_ptr );
                Inc(has_edge_ptr);
              end; {$endregion}

          end;

        2:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if cnc_ends then
              with eds_big_img do
                begin
                  x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x;
                  y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y;
                  x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x;
                  y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y;
                  ClippedLine1
                  (
                    x0,
                    y0,
                    x1,
                    y1,
                    rct_out,
                    Unaligned(@LinePHL  ),
                    Unaligned(@LinePHL02),
                    Unaligned(@LineSHL00)
                  );
                  if (Abs(y1-y0)<Abs(x1-x0)) then
                    ClippedLine1
                    (
                      x0+0,
                      y0+1,
                      x1+0,
                      y1+1,
                      rct_out,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL02),
                      Unaligned(@LineSHL00)
                    )
                  else
                    ClippedLine1
                    (
                      x0+1,
                      y0+0,
                      x1+1,
                      y1+0,
                      rct_out,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL02),
                      Unaligned(@LineSHL00)
                    );
                end; {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              with eds_big_img do
                begin
                  if (has_edge_ptr^=0{1}) then
                    begin
                      x0:=Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x;
                      y0:=Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y;
                      x1:=Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x;
                      y1:=Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y;
                      ClippedLine1
                      (
                        x0,
                        y0,
                        x1,
                        y1,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL02),
                        Unaligned(@LineSHL00)
                      );
                      if (Abs(y1-y0)<Abs(x1-x0)) then
                        ClippedLine1
                        (
                          x0+0,
                          y0+1,
                          x1+0,
                          y1+1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL02),
                          Unaligned(@LineSHL00)
                        )
                      else
                        ClippedLine1
                        (
                          x0+1,
                          y0+0,
                          x1+1,
                          y1+0,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL02),
                          Unaligned(@LineSHL00)
                        );
                    end;
                  Inc(sln_pts_ptr );
                  Inc(has_edge_ptr);
                end; {$endregion}

          end;
        3:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if cnc_ends then
              with eds_big_img do
                begin
                  x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x;
                  y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y;
                  x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x;
                  y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y;
                  ClippedLine1
                  (
                    x0,
                    y0,
                    x1,
                    y1,
                    rct_out,
                    Unaligned(@LinePHL  ),
                    Unaligned(@LinePHL02),
                    Unaligned(@LineSHL00)
                  );
                  if (Abs(y1-y0)<Abs(x1-x0)) then
                    begin
                      ClippedLine1
                      (
                        x0+0,
                        y0+1,
                        x1+0,
                        y1+1,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL02),
                        Unaligned(@LineSHL00)
                      );
                      ClippedLine1
                      (
                        x0+0,
                        y0-1,
                        x1+0,
                        y1-1,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL02),
                        Unaligned(@LineSHL00)
                      );
                    end
                  else
                    begin
                      ClippedLine1
                      (
                        x0+1,
                        y0+0,
                        x1+1,
                        y1+0,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL02),
                        Unaligned(@LineSHL00)
                      );
                      ClippedLine1
                      (
                        x0-1,
                        y0+0,
                        x1-1,
                        y1+0,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL02),
                        Unaligned(@LineSHL00)
                      );
                    end;
                end; {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              with eds_big_img do
                begin
                  if (has_edge_ptr^=0{1}) then
                    begin
                      x0:=Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x;
                      y0:=Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y;
                      x1:=Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x;
                      y1:=Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y;
                      ClippedLine1
                      (
                        x0,
                        y0,
                        x1,
                        y1,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL02),
                        Unaligned(@LineSHL00)
                      );
                      if (Abs(y1-y0)<Abs(x1-x0)) then
                        begin
                          ClippedLine1
                          (
                            x0+0,
                            y0+1,
                            x1+0,
                            y1+1,
                            rct_out,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL02),
                            Unaligned(@LineSHL00)
                          );
                          ClippedLine1
                          (
                            x0+0,
                            y0-1,
                            x1+0,
                            y1-1,
                            rct_out,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL02),
                            Unaligned(@LineSHL00)
                          );
                        end
                      else
                        begin
                          ClippedLine1
                          (
                            x0+1,
                            y0+0,
                            x1+1,
                            y1+0,
                            rct_out,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL02),
                            Unaligned(@LineSHL00)
                          );
                          ClippedLine1
                          (
                            x0-1,
                            y0+0,
                            x1-1,
                            y1+0,
                            rct_out,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL02),
                            Unaligned(@LineSHL00)
                          );
                        end;
                    end;
                  Inc(sln_pts_ptr );
                  Inc(has_edge_ptr);
                end; {$endregion}

          end;
      end;

    end;
end; {$endregion}
procedure TCurve.AddSplineEds7     (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr    : PObjInfo;
  rct_out        : TPtRect;
  sln_pts_ptr    : PPtPosF;
  has_edge_ptr   : PShortInt;
  useless_arr_ptr: PByte;
  x0,y0,x1,y1,b,i: integer;
begin
  with eds_img_arr[spline_ind],local_prop do
    begin

      {Misc. Precalc.------------------------------------------------------------------} {$region -fold}
      hid_ln_cnt     :=0;
      b              :=partial_pts_sum[spline_ind];
      obj_arr_ptr    :=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr    :=Unaligned(@sln_pts    [b]);
      has_edge_ptr   :=Unaligned(@has_edge   [b]);
      useless_arr_ptr:=Unaligned(@useless_arr[0]);
      rct_out        :=PtRct(rct_out_ptr^.left  +0,
                             rct_out_ptr^.top   +0,
                             rct_out_ptr^.right -1,
                             rct_out_ptr^.bottom-1); {$endregion}

      case eds_width of
        1:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if cnc_ends then
              with eds_big_img do
                ClippedLine1
                (
                  Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x,
                  Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y,
                  Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x,
                  Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y,
                  rct_out,
                  Unaligned(@LinePHL  ),
                  Unaligned(@LinePHL02),
                  Unaligned(@LineSHL00)
                ); {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              with eds_big_img do
                begin
                  if (useless_arr_ptr^=1) then
                    if (has_edge_ptr^=0{1}) then
                      begin
                        ClippedLine1
                        (
                          Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x,
                          Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y,
                          Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x,
                          Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL02),
                          Unaligned(@LineSHL00)
                        );
                      end;
                  Inc(sln_pts_ptr    );
                  Inc(has_edge_ptr   );
                  Inc(useless_arr_ptr);
                end; {$endregion}

          end;

        2:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if cnc_ends then
              with eds_big_img do
                begin
                  x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x;
                  y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y;
                  x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x;
                  y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y;
                  ClippedLine1
                  (
                    x0,
                    y0,
                    x1,
                    y1,
                    rct_out,
                    Unaligned(@LinePHL  ),
                    Unaligned(@LinePHL02),
                    Unaligned(@LineSHL00)
                  );
                  if (Abs(y1-y0)<Abs(x1-x0)) then
                    ClippedLine1
                    (
                      x0+0,
                      y0+1,
                      x1+0,
                      y1+1,
                      rct_out,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL02),
                      Unaligned(@LineSHL00)
                    )
                  else
                    ClippedLine1
                    (
                      x0+1,
                      y0+0,
                      x1+1,
                      y1+0,
                      rct_out,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL02),
                      Unaligned(@LineSHL00)
                    );
                end; {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              with eds_big_img do
                begin
                  if (useless_arr_ptr^=1) then
                    if (has_edge_ptr^=0{1}) then
                      begin
                        x0:=Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y0:=Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        x1:=Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y1:=Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        ClippedLine1
                        (
                          x0,
                          y0,
                          x1,
                          y1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL02),
                          Unaligned(@LineSHL00)
                        );
                        if (Abs(y1-y0)<Abs(x1-x0)) then
                          ClippedLine1
                          (
                            x0+0,
                            y0+1,
                            x1+0,
                            y1+1,
                            rct_out,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL02),
                            Unaligned(@LineSHL00)
                          )
                        else
                          ClippedLine1
                          (
                            x0+1,
                            y0+0,
                            x1+1,
                            y1+0,
                            rct_out,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL02),
                            Unaligned(@LineSHL00)
                          );
                      end;
                  Inc(sln_pts_ptr    );
                  Inc(has_edge_ptr   );
                  Inc(useless_arr_ptr);
                end; {$endregion}

          end;
        3:
          begin

            {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
            if cnc_ends then
              with eds_big_img do
                begin
                  x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+obj_arr_ptr^.world_axis_shift.x;
                  y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+obj_arr_ptr^.world_axis_shift.y;
                  x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+obj_arr_ptr^.world_axis_shift.x;
                  y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+obj_arr_ptr^.world_axis_shift.y;
                  ClippedLine1
                  (
                    x0,
                    y0,
                    x1,
                    y1,
                    rct_out,
                    Unaligned(@LinePHL  ),
                    Unaligned(@LinePHL02),
                    Unaligned(@LineSHL00)
                  );
                  if (Abs(y1-y0)<Abs(x1-x0)) then
                    begin
                      ClippedLine1
                      (
                        x0+0,
                        y0+1,
                        x1+0,
                        y1+1,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL02),
                        Unaligned(@LineSHL00)
                      );
                      ClippedLine1
                      (
                        x0+0,
                        y0-1,
                        x1+0,
                        y1-1,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL02),
                        Unaligned(@LineSHL00)
                      );
                    end
                  else
                    begin
                      ClippedLine1
                      (
                        x0+1,
                        y0+0,
                        x1+1,
                        y1+0,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL02),
                        Unaligned(@LineSHL00)
                      );
                      ClippedLine1
                      (
                        x0-1,
                        y0+0,
                        x1-1,
                        y1+0,
                        rct_out,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL02),
                        Unaligned(@LineSHL00)
                      );
                    end;
                end; {$endregion}

            {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
            for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
              with eds_big_img do
                begin
                  if (useless_arr_ptr^=1) then
                    if (has_edge_ptr^=0{1}) then
                      begin
                        x0:=Trunc((sln_pts_ptr+0)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y0:=Trunc((sln_pts_ptr+0)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        x1:=Trunc((sln_pts_ptr+1)^.x)+obj_arr_ptr^.world_axis_shift.x;
                        y1:=Trunc((sln_pts_ptr+1)^.y)+obj_arr_ptr^.world_axis_shift.y;
                        ClippedLine1
                        (
                          x0,
                          y0,
                          x1,
                          y1,
                          rct_out,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL02),
                          Unaligned(@LineSHL00)
                        );
                        if (Abs(y1-y0)<Abs(x1-x0)) then
                          begin
                            ClippedLine1
                            (
                              x0+0,
                              y0+1,
                              x1+0,
                              y1+1,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL02),
                              Unaligned(@LineSHL00)
                            );
                            ClippedLine1
                            (
                              x0+0,
                              y0-1,
                              x1+0,
                              y1-1,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL02),
                              Unaligned(@LineSHL00)
                            );
                          end
                        else
                          begin
                            ClippedLine1
                            (
                              x0+1,
                              y0+0,
                              x1+1,
                              y1+0,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL02),
                              Unaligned(@LineSHL00)
                            );
                            ClippedLine1
                            (
                              x0-1,
                              y0+0,
                              x1-1,
                              y1+0,
                              rct_out,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL02),
                              Unaligned(@LineSHL00)
                            );
                          end;
                      end;
                  Inc(sln_pts_ptr    );
                  Inc(has_edge_ptr   );
                  Inc(useless_arr_ptr);
                end; {$endregion}

          end;
      end;

    end;
end; {$endregion}
procedure TCurve.AddSplinePts0     (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr    : PObjInfo;
  dup_pts_arr_ptr: PPtPos2;
  sln_pts_ptr    : PPtPosF;
  pt             : TPtPos;
  b,i            : integer;
begin
  with pts_img_arr[spline_ind],local_prop do
    begin
      b          :=partial_pts_sum[spline_ind];
      obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr:=Unaligned(@sln_pts[b]);
      for i:=0 to sln_obj_pts_cnt[spline_ind]-1 do
        begin
          pt:=PtPos(Trunc(sln_pts_ptr^.x)+obj_arr_ptr^.world_axis_shift.x,
                    Trunc(sln_pts_ptr^.y)+obj_arr_ptr^.world_axis_shift.y);
          if IsPtInRct(pt.x,pt.y,rct_out_ptr^) then
            begin
              dup_pts_arr_ptr:=Unaligned(@dup_pts_arr[pt.x+pt.y*pts_big_img.ln_arr_width]);
              if (dup_pts_arr_ptr^*dup_pts_id    ) and
                 (dup_pts_arr_ptr^.dup_pts_cnt =0) then
                begin
                  dup_pts_arr_ptr^.dup_pts_cnt:=1;
                  Rectangle
                  (
                    pt.x,
                    pt.y,
                    pts_big_img.ln_arr1_ptr,
                    pts_big_img.ln_arr_width,
                    pts_big_img.ln_arr_height,
                    PtRct(rct_vis),
                    local_prop,
                    @PPFloodFillAdd
                  );
                end;
            end
          else
            Rectangle
            (
              pt.x,
              pt.y,
              pts_big_img.ln_arr1_ptr,
              pts_big_img.ln_arr_width,
              pts_big_img.ln_arr_height,
              PtRct(rct_vis),
              local_prop,
              @PPFloodFillAdd
            );
          Inc(sln_pts_ptr);
        end;
    end;
end; {$endregion}
procedure TCurve.AddSplinePts1     (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr    : PObjInfo;
  dup_pts_arr_ptr: PPtPos2;
  sln_pts_ptr    : PPtPosF;
  pt             : TPtPos;
  b,i            : integer;
begin
  with pts_img_arr[spline_ind],local_prop do
    begin
      b          :=partial_pts_sum[spline_ind];
      obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr:=Unaligned(@sln_pts[b]);
      for i:=0 to sln_obj_pts_cnt[spline_ind]-1 do
        begin
          if (not sel_var.is_point_selected[b+i]) then
            begin
              pt:=PtPos(Trunc(sln_pts_ptr^.x)+obj_arr_ptr^.world_axis_shift.x,
                        Trunc(sln_pts_ptr^.y)+obj_arr_ptr^.world_axis_shift.y);
              if IsPtInRct(pt.x,pt.y,rct_out_ptr^) then
                begin
                  dup_pts_arr_ptr:=Unaligned(@dup_pts_arr[pt.x+pt.y*pts_big_img.ln_arr_width]);
                  if (dup_pts_arr_ptr^*dup_pts_id    ) and
                     (dup_pts_arr_ptr^.dup_pts_cnt =0) then
                    begin
                      dup_pts_arr_ptr^.dup_pts_cnt:=1;
                      Rectangle
                      (
                        pt.x,
                        pt.y,
                        pts_big_img.ln_arr1_ptr,
                        pts_big_img.ln_arr_width,
                        pts_big_img.ln_arr_height,
                        PtRct(rct_vis),
                        local_prop,
                        @PPFloodFillAdd
                      );
                    end;
                end
              else
                Rectangle
                (
                  pt.x,
                  pt.y,
                  pts_big_img.ln_arr1_ptr,
                  pts_big_img.ln_arr_width,
                  pts_big_img.ln_arr_height,
                  PtRct(rct_vis),
                  local_prop,
                  @PPFloodFillAdd
                );
            end;
          Inc(sln_pts_ptr);
        end
    end;
end; {$endregion}
procedure TCurve.AddSplinePts2     (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr    : PObjInfo;
  dup_pts_arr_ptr: PPtPos2;
  sln_pts_ptr    : PPtPosF;
  pt             : TPtPos;
  b,i            : integer;
begin
  with pts_img_arr[spline_ind],local_prop do
    begin
      b          :=partial_pts_sum[spline_ind];
      obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr:=Unaligned(@sln_pts[b]);
      for i:=0 to sln_obj_pts_cnt[spline_ind]-1 do
        begin
          if sel_var.is_point_selected[b+i] then
            begin
              pt:=PtPos(Trunc(sln_pts_ptr^.x)+obj_arr_ptr^.world_axis_shift.x,
                        Trunc(sln_pts_ptr^.y)+obj_arr_ptr^.world_axis_shift.y);
              if IsPtInRct(pt.x,pt.y,rct_out_ptr^) then
                begin
                  dup_pts_arr_ptr:=Unaligned(@dup_pts_arr[pt.x+pt.y*pts_big_img.ln_arr_width]);
                  if (not (dup_pts_arr_ptr^*dup_pts_id)   ) and
                     (     dup_pts_arr_ptr^.dup_pts_cnt =0) then
                    begin
                           dup_pts_arr_ptr^.dup_pts_cnt:=1;
                      Rectangle
                      (
                        pt.x,
                        pt.y,
                        pts_big_img.ln_arr1_ptr,
                        pts_big_img.ln_arr_width,
                        pts_big_img.ln_arr_height,
                        PtRct(rct_vis),
                        local_prop,
                        @PPFloodFillAdd
                      );
                    end;
                end
              else
                Rectangle
                (
                  pt.x,
                  pt.y,
                  pts_big_img.ln_arr1_ptr,
                  pts_big_img.ln_arr_width,
                  pts_big_img.ln_arr_height,
                  PtRct(rct_vis),
                  local_prop,
                  @PPFloodFillAdd
                );
            end;
          Inc(sln_pts_ptr);
        end;
    end;
end; {$endregion}
procedure TCurve.AddSplinePts3     (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr    : PObjInfo;
  dup_pts_arr_ptr: PPtPos2;
  sln_pts_ptr    : PPtPosF;
  pt             : TPtPos;
  b,i            : integer;
begin
  with pts_img_arr[spline_ind],local_prop do
    begin
      b          :=partial_pts_sum[spline_ind];
      obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr:=Unaligned(@sln_pts[b]);
      for i:=0 to sln_obj_pts_cnt[spline_ind]-1 do
        begin
          if sel_var.is_point_selected[b+i] then
            begin
              pt:=PtPos(Trunc(sln_pts_ptr^.x)+obj_arr_ptr^.world_axis_shift.x,
                        Trunc(sln_pts_ptr^.y)+obj_arr_ptr^.world_axis_shift.y);
              if IsPtInRct(pt.x,pt.y,rct_out_ptr^) then
                begin
                  dup_pts_arr_ptr:=Unaligned(@dup_pts_arr[pt.x+pt.y*pts_big_img.ln_arr_width]);
                  if (dup_pts_arr_ptr^*dup_pts_id    ) and
                     (dup_pts_arr_ptr^.dup_pts_cnt =0) then
                    begin
                      dup_pts_arr_ptr^.dup_pts_cnt:=1;
                      Rectangle
                      (
                        pt.x,
                        pt.y,
                        pts_big_img.ln_arr1_ptr,
                        pts_big_img.ln_arr_width,
                        pts_big_img.ln_arr_height,
                        PtRct(rct_vis),
                        local_prop,
                        @PPFloodFillSub
                      );
                    end;
                end
              else
                Rectangle
                (
                  pt.x,
                  pt.y,
                  pts_big_img.ln_arr1_ptr,
                  pts_big_img.ln_arr_width,
                  pts_big_img.ln_arr_height,
                  PtRct(rct_vis),
                  local_prop,
                  @PPFloodFillSub
                );
            end;
          Inc(sln_pts_ptr);
        end;
    end;
end; {$endregion}
procedure TCurve.AddSplinePts4     (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr    : PObjInfo;
  dup_pts_arr_ptr: PPtPos2;
  sln_pts_ptr    : PPtPosF;
  pt             : TPtPos;
  b,i            : integer;
begin
  with pts_img_arr[spline_ind],local_prop do
    begin
      b          :=partial_pts_sum[spline_ind];
      obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr:=Unaligned(@sln_pts[b]);
      for i:=0 to sln_obj_pts_cnt[spline_ind]-1 do
        begin
          pt:=PtPos(Trunc(sln_pts_ptr^.x)+obj_arr_ptr^.world_axis_shift.x,
                    Trunc(sln_pts_ptr^.y)+obj_arr_ptr^.world_axis_shift.y);
          if IsPtInRct(pt.x,pt.y,rct_out_ptr^) then
            begin
              dup_pts_arr_ptr:=Unaligned(@dup_pts_arr[pt.x+pt.y*pts_big_img.ln_arr_width]);
              if (dup_pts_arr_ptr^*dup_pts_id    ) and
                 (dup_pts_arr_ptr^.dup_pts_cnt =0) then
                begin
                  dup_pts_arr_ptr^.dup_pts_cnt:=1;
                  Rectangle
                  (
                    pt.x,
                    pt.y,
                    pts_big_img.ln_arr0_ptr,
                    pts_big_img.ln_arr_width,
                    pts_big_img.ln_arr_height,
                    PtRct(rct_vis),
                    local_prop,
                    @PPFloodFill
                  );
                end;
            end
          else
            Rectangle
            (
              pt.x,
              pt.y,
              pts_big_img.ln_arr0_ptr,
              pts_big_img.ln_arr_width,
              pts_big_img.ln_arr_height,
              PtRct(rct_vis),
              local_prop,
              @PPFloodFill
            );
          Inc(sln_pts_ptr);
        end;
    end;
end; {$endregion}
procedure TCurve.AddSplinePts5     (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr    : PObjInfo;
  dup_pts_arr_ptr: PPtPos2;
  sln_pts_ptr    : PPtPosF;
  pt             : TPtPos;
  b,i            : integer;
begin
  with pts_img_arr[spline_ind],local_prop do
    begin
      b          :=partial_pts_sum[spline_ind];
      obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr:=Unaligned(@sln_pts[b]);
      for i:=0 to sln_obj_pts_cnt[spline_ind]-1 do
        begin
          if (not sel_var.is_point_selected[b+i]) then
            begin
              pt:=PtPos(Trunc(sln_pts_ptr^.x)+obj_arr_ptr^.world_axis_shift.x,
                        Trunc(sln_pts_ptr^.y)+obj_arr_ptr^.world_axis_shift.y);
              if IsPtInRct(pt.x,pt.y,rct_out_ptr^) then
                begin
                  dup_pts_arr_ptr:=Unaligned(@dup_pts_arr[pt.x+pt.y*pts_big_img.ln_arr_width]);
                  if (dup_pts_arr_ptr^*dup_pts_id    ) and
                     (dup_pts_arr_ptr^.dup_pts_cnt =0) then
                    begin
                      dup_pts_arr_ptr^.dup_pts_cnt:=1;
                      Rectangle
                      (
                        pt.x,
                        pt.y,
                        pts_big_img.ln_arr0_ptr,
                        pts_big_img.ln_arr_width,
                        pts_big_img.ln_arr_height,
                        PtRct(rct_vis),
                        local_prop,
                        @PPFloodFill
                      );
                    end;
                end
              else
                Rectangle
                (
                  pt.x,
                  pt.y,
                  pts_big_img.ln_arr0_ptr,
                  pts_big_img.ln_arr_width,
                  pts_big_img.ln_arr_height,
                  PtRct(rct_vis),
                  local_prop,
                  @PPFloodFill
                );
            end;
          Inc(sln_pts_ptr);
        end
    end;
end; {$endregion}
procedure TCurve.AddSplinePts6     (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr    : PObjInfo;
  dup_pts_arr_ptr: PPtPos2;
  sln_pts_ptr    : PPtPosF;
  pt             : TPtPos;
  b,i            : integer;
begin
  with pts_img_arr[spline_ind],local_prop do
    begin
      b          :=partial_pts_sum[spline_ind];
      obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr:=Unaligned(@sln_pts[b]);
      for i:=0 to sln_obj_pts_cnt[spline_ind]-1 do
        begin
          if sel_var.is_point_selected[b+i] then
            begin
              pt:=PtPos(Trunc(sln_pts_ptr^.x)+obj_arr_ptr^.world_axis_shift.x,
                        Trunc(sln_pts_ptr^.y)+obj_arr_ptr^.world_axis_shift.y);
              if IsPtInRct(pt.x,pt.y,rct_out_ptr^) then
                begin
                  dup_pts_arr_ptr:=Unaligned(@dup_pts_arr[pt.x+pt.y*pts_big_img.ln_arr_width]);
                  if (not (dup_pts_arr_ptr^*dup_pts_id)   ) and
                     (     dup_pts_arr_ptr^.dup_pts_cnt =0) then
                    begin
                           dup_pts_arr_ptr^.dup_pts_cnt:=1;
                      Rectangle
                      (
                        pt.x,
                        pt.y,
                        pts_big_img.ln_arr0_ptr,
                        pts_big_img.ln_arr_width,
                        pts_big_img.ln_arr_height,
                        PtRct(rct_vis),
                        local_prop,
                        @PPFloodFill
                      );
                    end;
                end
              else
                Rectangle
                (
                  pt.x,
                  pt.y,
                  pts_big_img.ln_arr0_ptr,
                  pts_big_img.ln_arr_width,
                  pts_big_img.ln_arr_height,
                  PtRct(rct_vis),
                  local_prop,
                  @PPFloodFill
                );
            end;
          Inc(sln_pts_ptr);
        end;
    end;
end; {$endregion}
procedure TCurve.AddSplinePts7     (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr    : PObjInfo;
  dup_pts_arr_ptr: PPtPos2;
  sln_pts_ptr    : PPtPosF;
  pt             : TPtPos;
  b,i            : integer;
begin
  with pts_img_arr[spline_ind],local_prop do
    begin
      b          :=partial_pts_sum[spline_ind];
      obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr:=Unaligned(@sln_pts[b]);
      for i:=0 to sln_obj_pts_cnt[spline_ind]-1 do
        begin
          if sel_var.is_point_selected[b+i] then
            begin
              pt:=PtPos(Trunc(sln_pts_ptr^.x)+obj_arr_ptr^.world_axis_shift.x,
                        Trunc(sln_pts_ptr^.y)+obj_arr_ptr^.world_axis_shift.y);
              if IsPtInRct(pt.x,pt.y,rct_out_ptr^) then
                begin
                  dup_pts_arr_ptr:=Unaligned(@dup_pts_arr[pt.x+pt.y*pts_big_img.ln_arr_width]);
                  if (dup_pts_arr_ptr^*dup_pts_id    ) and
                     (dup_pts_arr_ptr^.dup_pts_cnt =0) then
                    begin
                      dup_pts_arr_ptr^.dup_pts_cnt:=1;
                      Rectangle
                      (
                        pt.x,
                        pt.y,
                        pts_big_img.ln_arr0_ptr,
                        pts_big_img.ln_arr_width,
                        pts_big_img.ln_arr_height,
                        PtRct(rct_vis),
                        local_prop,
                        @PPFloodFill
                      );
                    end;
                end
              else
                Rectangle
                (
                  pt.x,
                  pt.y,
                  pts_big_img.ln_arr0_ptr,
                  pts_big_img.ln_arr_width,
                  pts_big_img.ln_arr_height,
                  PtRct(rct_vis),
                  local_prop,
                  @PPFloodFill
                );
            end;
          Inc(sln_pts_ptr);
        end;
    end;
end; {$endregion}
procedure TCurve.AddSplineDupPts0  (constref spline_ind       :TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
  sln_pts_ptr: PPtPosF;
  pt         : TPtPos;
  b,i        : integer;
begin
  with pts_img_arr[spline_ind],local_prop do
    begin
      b          :=partial_pts_sum[spline_ind];
      obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr:=Unaligned(@sln_pts[b]);
      for i:=0 to sln_obj_pts_cnt[spline_ind]-1 do
        begin
          pt:=PtPos(Trunc(sln_pts_ptr^.x)+obj_arr_ptr^.world_axis_shift.x,
                    Trunc(sln_pts_ptr^.y)+obj_arr_ptr^.world_axis_shift.y);
          if IsPtInRct(pt.x,pt.y,rct_out_ptr^) then
            dup_pts_id.SetEqual2(dup_pts_arr[pt.x+pt.y*pts_big_img.ln_arr_width],dup_pts_id);
          Inc(sln_pts_ptr);
        end;
    end;
end; {$endregion}
procedure TCurve.AddSplineDupPts1  (constref spline_ind       :TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
  sln_pts_ptr: PPtPosF;
  pt         : TPtPos;
  b,i        : integer;
begin
  with pts_img_arr[spline_ind],local_prop do
    begin
      b          :=partial_pts_sum[spline_ind];
      obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr:=Unaligned(@sln_pts[b]);
      for i:=0 to sln_obj_pts_cnt[spline_ind]-1 do
        begin
          if (not sel_var.is_point_selected[b+i]) then
            begin
              pt:=PtPos(Trunc(sln_pts_ptr^.x)+obj_arr_ptr^.world_axis_shift.x,
                        Trunc(sln_pts_ptr^.y)+obj_arr_ptr^.world_axis_shift.y);
              if IsPtInRct(pt.x,pt.y,rct_out_ptr^) then
                dup_pts_id.SetEqual2(dup_pts_arr[pt.x+pt.y*pts_big_img.ln_arr_width],dup_pts_id);
            end;
          Inc(sln_pts_ptr);
        end;
    end;
end; {$endregion}
procedure TCurve.AddSplineDupPts2  (constref spline_ind       :TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
  sln_pts_ptr: PPtPosF;
  pt         : TPtPos;
  b,i        : integer;
begin
  with pts_img_arr[spline_ind],local_prop do
    begin
      b          :=partial_pts_sum[spline_ind];
      obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr:=Unaligned(@sln_pts[b]);
      for i:=0 to sln_obj_pts_cnt[spline_ind]-1 do
        begin
          if (not sel_var.is_point_selected[b+i]) then
            begin
              pt:=PtPos(Trunc(sln_pts_ptr^.x)+obj_arr_ptr^.world_axis_shift.x,
                        Trunc(sln_pts_ptr^.y)+obj_arr_ptr^.world_axis_shift.y);
              if IsPtInRct(pt.x,pt.y,rct_out_ptr^) then
                dup_pts_id.SetEqual2(dup_pts_arr[pt.x+pt.y*pts_big_img.ln_arr_width],dup_pts_id);
            end;
          Inc(sln_pts_ptr);
        end;
    end;
end; {$endregion}
procedure TCurve.AddSplineDupPts3  (constref spline_ind       :TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
  sln_pts_ptr: PPtPosF;
  pt         : TPtPos;
  b,i        : integer;
begin
  with pts_img_arr[spline_ind],local_prop do
    begin
      b          :=partial_pts_sum[spline_ind];
      obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr:=Unaligned(@sln_pts[b]);
      for i:=0 to sln_obj_pts_cnt[spline_ind]-1 do
        begin
          if sel_var.is_point_selected[b+i] then
            begin
              pt:=PtPos(Trunc(sln_pts_ptr^.x)+obj_arr_ptr^.world_axis_shift.x,
                        Trunc(sln_pts_ptr^.y)+obj_arr_ptr^.world_axis_shift.y);
              if IsPtInRct(pt.x,pt.y,rct_out_ptr^) then
                dup_pts_id.SetEqual2(dup_pts_arr[pt.x+pt.y*pts_big_img.ln_arr_width],dup_pts_id);
            end;
          Inc(sln_pts_ptr);
        end;
    end;
end; {$endregion}
procedure TCurve.AddSplineDupPtsAll(constref start_ind,end_ind:TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
  sln_pts_ptr: PPtPosF;
  pt         : TPtPos;
  b,i,j      : integer;
begin
  for j:=start_ind to end_ind do
    with pts_img_arr[j] do
      begin
        b          :=partial_pts_sum[j];
        obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[j]]);
        sln_pts_ptr:=Unaligned(@sln_pts[b]);
        for i:=0 to sln_obj_pts_cnt[j]-1 do
          begin
            pt:=PtPos(Trunc(sln_pts_ptr^.x)+obj_arr_ptr^.world_axis_shift.x,
                      Trunc(sln_pts_ptr^.y)+obj_arr_ptr^.world_axis_shift.y);
            if IsPtInRct(pt.x,pt.y,rct_out_ptr^) then
              dup_pts_arr[pt.x+pt.y*pts_big_img.ln_arr_width].obj_ind:=j;
            Inc(sln_pts_ptr);
          end;
      end;
end; {$endregion}
procedure TCurve.ClrSplineDupPts0  (constref spline_ind       :TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
  sln_pts_ptr: PPtPosF;
  pt         : TPtPos;
  b,i        : integer;
begin
  with pts_img_arr[spline_ind],local_prop do
    begin
      b          :=partial_pts_sum[spline_ind];
      obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr:=Unaligned(@sln_pts[b]);
      for i:=0 to sln_obj_pts_cnt[spline_ind]-1 do
        begin
          pt:=PtPos(Trunc(sln_pts_ptr^.x)+obj_arr_ptr^.world_axis_shift.x,
                    Trunc(sln_pts_ptr^.y)+obj_arr_ptr^.world_axis_shift.y);
          if IsPtInRct(pt.x,pt.y,rct_out_ptr^) then
            dup_pts_id.SetEqual1(dup_pts_arr[pt.x+pt.y*pts_big_img.ln_arr_width],Default(TPtPos2));
          Inc(sln_pts_ptr);
        end;
    end;
end; {$endregion}
procedure TCurve.ClrSplineDupPts1  (constref spline_ind       :TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
  sln_pts_ptr: PPtPosF;
  pt         : TPtPos;
  b,i        : integer;
begin
  with pts_img_arr[spline_ind],local_prop do
    begin
      b          :=partial_pts_sum[spline_ind];
      obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr:=Unaligned(@sln_pts[b]);
      for i:=0 to sln_obj_pts_cnt[spline_ind]-1 do
        begin
          if (not sel_var.is_point_selected[b+i]) then
            begin
              pt:=PtPos(Trunc(sln_pts_ptr^.x)+obj_arr_ptr^.world_axis_shift.x,
                        Trunc(sln_pts_ptr^.y)+obj_arr_ptr^.world_axis_shift.y);
              if IsPtInRct(pt.x,pt.y,rct_out_ptr^) then
                dup_pts_id.SetEqual1(dup_pts_arr[pt.x+pt.y*pts_big_img.ln_arr_width],Default(TPtPos2));
            end;
          Inc(sln_pts_ptr);
        end;
    end;
end; {$endregion}
procedure TCurve.ClrSplineDupPts2  (constref spline_ind       :TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
  sln_pts_ptr: PPtPosF;
  pt         : TPtPos;
  b,i        : integer;
begin
  with pts_img_arr[spline_ind],local_prop do
    begin
      b          :=partial_pts_sum[spline_ind];
      obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr:=Unaligned(@sln_pts[b]);
      for i:=0 to sln_obj_pts_cnt[spline_ind]-1 do
        begin
          begin
            pt:=PtPos(Trunc(sln_pts_ptr^.x)+obj_arr_ptr^.world_axis_shift.x,
                      Trunc(sln_pts_ptr^.y)+obj_arr_ptr^.world_axis_shift.y);
            if IsPtInRct(pt.x,pt.y,rct_out_ptr^) then
              dup_pts_id.SetEqual1(dup_pts_arr[pt.x+pt.y*pts_big_img.ln_arr_width],Default(TPtPos2));
          end;
          Inc(sln_pts_ptr);
        end;
    end;
end; {$endregion}
procedure TCurve.ClrSplineDupPts3  (constref spline_ind       :TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
  sln_pts_ptr: PPtPosF;
  pt         : TPtPos;
  b,i        : integer;
begin
  with pts_img_arr[spline_ind],local_prop do
    begin
      b          :=partial_pts_sum[spline_ind];
      obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]]);
      sln_pts_ptr:=Unaligned(@sln_pts[b]);
      for i:=0 to sln_obj_pts_cnt[spline_ind]-1 do
        begin
          if sel_var.is_point_selected[b+i] then
            begin
              pt:=PtPos(Trunc(sln_pts_ptr^.x)+obj_arr_ptr^.world_axis_shift.x,
                        Trunc(sln_pts_ptr^.y)+obj_arr_ptr^.world_axis_shift.y);
              if IsPtInRct(pt.x,pt.y,rct_out_ptr^) then
                dup_pts_id.SetEqual1(dup_pts_arr[pt.x+pt.y*pts_big_img.ln_arr_width],Default(TPtPos2));
            end;
          Inc(sln_pts_ptr);
        end;
    end;
end; {$endregion}
procedure TCurve.ClrSplineRctEds   (constref spline_ind       :TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with rct_eds_img_arr[spline_ind],local_prop,fst_img do
    if (rct_eds_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) and (nt_pix_cnt<>0) then
      begin
        NTBeginProc[2];
        NTColorProc[0];
      end;
end; {$endregion}
procedure TCurve.ClrSplineRctPts   (constref spline_ind       :TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with rct_pts_img_arr[spline_ind],local_prop,fst_img do
    if (rct_pts_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) and (nt_pix_cnt<>0) then
      begin
        NTBeginProc[2];
        NTColorProc[0];
      end;
end; {$endregion}
procedure TCurve.ClrSplineEds      (constref spline_ind       :TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with eds_img_arr[spline_ind],local_prop,fst_img do
    if (eds_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) and (nt_pix_cnt<>0) then
      begin
        NTBeginProc[2];
        NTColorProc[0];
      end;
end; {$endregion}
procedure TCurve.ClrSplinePts      (constref spline_ind       :TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with pts_img_arr[spline_ind],local_prop,fst_img do
    if (pts_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) and (nt_pix_cnt<>0) then
      begin
        NTBeginProc[2];
        NTColorProc[0];
      end;
end; {$endregion}
procedure TCurve.ClrSplineAll      (constref start_ind,end_ind:TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i,j,k: integer;
begin
  for i:=sln_obj_cnt-1 downto 0 do
    begin
      j:=obj_var.curve_inds_sct_arr[i];
      if (j>=start_ind) and (j<=end_ind) then
        begin
          k:=obj_var.obj_arr[obj_var.obj_inds_arr[j]].k_ind;
          ClrSplinePts   (k);
          ClrSplineEds   (k);
          ClrSplineRctPts(k);
          ClrSplineRctEds(k);
        end;
    end;
end; {$endregion}
procedure TCurve.CrtSplineRctEds   (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with rct_eds_img_arr[spline_ind],local_prop do
    begin

      {Create Sprite--} {$region -fold}
      if (fst_img=Nil) then
          fst_img:=TFastImage.Create
          (
            bmp_dst_ptr,
            bmp_dst_width,
            bmp_dst_height,
            rct_out_ptr^,
            PtRct(rct_vis),
            0
          ); {$endregion}

      {Compress Sprite} {$region -fold}
      // clear buffers:
      fst_img.ClrArr({%0000011111111111}%0000000011111111);
      // set color of edges  bounding rectangle sprite:
      fst_img.SetPPInfo(clRed);
      // compress edges  bounding rectangle sprite:
      PrimitiveComp(spline_ind,@rct_eds_img_arr[spline_ind],@rct_eds_big_img,dsAlphablend); {$endregion}

      {Clear Buffer---} {$region -fold}
      fst_img.FilNTValueArrA(rct_eds_big_img.ln_arr1,
                             rct_eds_big_img.ln_arr_width); {$endregion}

    end;
end; {$endregion}
procedure TCurve.CrtSplineRctPts   (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with rct_pts_img_arr[spline_ind],local_prop do
    begin

      {Create Sprite--} {$region -fold}
      if (fst_img=Nil) then
          fst_img:=TFastImage.Create
          (
            bmp_dst_ptr,
            bmp_dst_width,
            bmp_dst_height,
            rct_out_ptr^,
            PtRct(rct_vis),
            0
          ); {$endregion}

      {Compress Sprite} {$region -fold}
      // clear buffers:
      fst_img.ClrArr({%0000011111111111}%0000000011111111);
      // set color of edges  bounding rectangle sprite:
      fst_img.SetPPInfo(clBlue);
      // compress edges  bounding rectangle sprite:
      PrimitiveComp(spline_ind,@rct_pts_img_arr[spline_ind],@rct_pts_big_img,dsAlphablend); {$endregion}

      {Clear Buffer---} {$region -fold}
      fst_img.FilNTValueArrA(rct_pts_big_img.ln_arr1,
                             rct_pts_big_img.ln_arr_width); {$endregion}

    end;
end; {$endregion}
procedure TCurve.CrtSplineEds      (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with eds_img_arr[spline_ind],local_prop do
    begin

      {Create Sprite--} {$region -fold}
      if (fst_img=Nil) then
          fst_img:=TFastImage.Create
          (
            bmp_dst_ptr,
            bmp_dst_width,
            bmp_dst_height,
            rct_out_ptr^,
            PtRct(rct_vis),
            0
          ); {$endregion}

      {Compress Sprite} {$region -fold}
      // clear buffers:
      fst_img.ClrArr({%0000011111111111}%0000000011111111);

      // set color of spline edges:
      fst_img.SetPPInfo(eds_col);

      // compress edges sprite:
      PrimitiveComp(spline_ind,@eds_img_arr[spline_ind],@eds_big_img,eds_bld_stl); {$endregion}

      {Antialiasing---} {$region -fold}
      {if sln_eds_var_ptr^.spline_local_prop.ed_aa then
        begin
          BorderCalc1
          (
            sln_eds_var_ptr^.f_ln_arr1 ,
            sln_eds_var_ptr^.f_brd_arr1,
            sln_eds_var_ptr^.f_bmp_width,
            sln_eds_var_ptr^.f_bmp_width,
            0,
            0,
            sln_eds_var_ptr^.obj_rect_vis.Width ,
            sln_eds_var_ptr^.obj_rect_vis.Height,
            sln_eds_var_ptr^.aa_nz_arr_items_count
          );
          BorderCalc2
          (
            sln_eds_var_ptr^.f_ln_arr1 ,
            sln_eds_var_ptr^.f_brd_arr1,
            sln_eds_var_ptr^.f_brd_arr2,
            sln_eds_var_ptr^.f_bmp_width,
            sln_eds_var_ptr^.f_bmp_width,
            0,
            0,
            sln_eds_var_ptr^.obj_rect_vis.Width ,
            sln_eds_var_ptr^.obj_rect_vis.Height,
            sln_eds_var_ptr^.aa_line_count
          );
          BorderFill
          (
            sln_eds_var_ptr^.f_brd_arr2,
            sln_eds_var_ptr^.obj_rect_vis.Left,
            sln_eds_var_ptr^.obj_rect_vis.Top,
            m_c_var.srf_bmp_ptr,
            m_c_var.srf_bmp.Width ,
            sln_eds_var_ptr^.aa_line_count,
            sln_eds_var_ptr^.spline_local_prop.ed_color
          );
        end;} {$endregion}

      {Clear Buffer---} {$region -fold}
      if byte_mode and (not down_select_points_ptr^) then
        fst_img.FilNTValueArrB(eds_big_img.ln_arr0,
                               eds_big_img.ln_arr_width)
      else
        fst_img.FilNTValueArrA(eds_big_img.ln_arr1,
                               eds_big_img.ln_arr_width); {$endregion}

    end;
end; {$endregion}
procedure TCurve.CrtSplinePts      (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with pts_img_arr[spline_ind],local_prop do
    begin

      {Create Sprite--} {$region -fold}
      if (fst_img=Nil) then
          fst_img:=TFastImage.Create
          (
            bmp_dst_ptr,
            bmp_dst_width,
            bmp_dst_height,
            rct_out_ptr^,
            PtRct(rct_vis),
            0
          ); {$endregion}

      {Compress Sprite} {$region -fold}
      // clear buffers:
      fst_img.ClrArr({%0000011111111111}%0000000011111111);

      // set color of spline points:
      fst_img.SetPPInfo(pts_col);

      // compress points sprite:
      PrimitiveComp(spline_ind,@pts_img_arr[spline_ind],@pts_big_img,pts_bld_stl); {$endregion}

      {Clear Buffer---} {$region -fold}
      if byte_mode and (not down_select_points_ptr^) then
        fst_img.FilNTValueArrB(pts_big_img.ln_arr0,
                               pts_big_img.ln_arr_width)
      else
        fst_img.FilNTValueArrA(pts_big_img.ln_arr1,
                               pts_big_img.ln_arr_width); {$endregion}

    end;
end; {$endregion}
procedure TCurve.CrtSplineAll0     (constref start_ind,end_ind:TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i,j: integer;
begin
  for i:=start_ind to end_ind do
    begin
      j:=obj_var.obj_arr[obj_var.curve_inds_obj_arr[i]].t_ind;
      if (j>=start_ind) and (j<=end_ind) then
        begin
          CrtSplineRctEds(i);
          CrtSplineRctPts(i);
          CrtSplineEds   (i);
          CrtSplinePts   (i);
        end;
    end;
end; {$endregion}
procedure TCurve.CrtSplineAll1     (constref start_ind,end_ind:TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i,j: integer;
begin
  for i:=start_ind to end_ind do
    begin
      j:=obj_var.obj_arr[obj_var.curve_inds_obj_arr[i]].t_ind;
      if (j>=start_ind) and (j<=end_ind) then
        begin
          if (has_sel_pts[i]=0) then
            Continue;
          CrtSplineRctEds(i);
          CrtSplineRctPts(i);
          CrtSplineEds   (i);
          CrtSplinePts   (i);
        end;
    end;
end; {$endregion}
procedure TCurve.FilSplineRctEds   (constref spline_ind       :TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  with rct_eds_img_arr[spline_ind],local_prop,fst_img do
    if (rct_eds_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) and (nt_pix_cnt<>0) then
      begin
        if lazy_repaint_prev and lazy_repaint then
          begin
            SetRctPos(rct_vis.left,rct_vis.top);
            bmp_src_rct_clp:=PtRct(rct_vis);
          end;
        if down_select_points_ptr^ then
          StrNTLowerBmpA;
        for i:=0 to   fx_arr[0].rep_cnt-1 do
          NTValueProc[fx_arr[0].nt_value_proc_ind];
      end;
end; {$endregion}
procedure TCurve.FilSplineRctPts   (constref spline_ind       :TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  with rct_pts_img_arr[spline_ind],local_prop,fst_img do
    if (rct_pts_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) and (nt_pix_cnt<>0) then
      begin
        if lazy_repaint_prev and lazy_repaint then
          begin
            SetRctPos(rct_vis.left,rct_vis.top);
            bmp_src_rct_clp:=PtRct(rct_vis);
          end;
        if down_select_points_ptr^ then
          StrNTLowerBmpA;
        for i:=0 to   fx_arr[0].rep_cnt-1 do
          NTValueProc[fx_arr[0].nt_value_proc_ind];
      end;
end; {$endregion}
procedure TCurve.FilSplineEds      (constref spline_ind       :TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  with eds_img_arr[spline_ind],local_prop,fst_img do
    if (eds_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) and (nt_pix_cnt<>0) then
      begin
        if lazy_repaint_prev and lazy_repaint then
          begin
            SetRctPos(rct_vis.left,rct_vis.top);
            bmp_src_rct_clp:=PtRct(rct_vis);
          end;
        if down_select_points_ptr^ then
          StrNTLowerBmpA;
        for i:=0 to   fx_arr[0].rep_cnt-1 do
          NTValueProc[fx_arr[0].nt_value_proc_ind];
      end;
end; {$endregion}
procedure TCurve.FilSplinePts      (constref spline_ind       :TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  with pts_img_arr[spline_ind],local_prop,fst_img do
    if (pts_show and (not IsRct1OutOfRct2(rct_ent,rct_out_ptr^))) and (nt_pix_cnt<>0) then
      begin
        if lazy_repaint_prev and lazy_repaint then
          begin
            SetRctPos(rct_vis.left,rct_vis.top);
            bmp_src_rct_clp:=PtRct(rct_vis);
          end;
        if down_select_points_ptr^ then
          StrNTLowerBmpA;
        for i:=0 to   fx_arr[0].rep_cnt-1 do
          NTValueProc[fx_arr[0].nt_value_proc_ind];
      end;
end; {$endregion}
procedure TCurve.FilSplineObj      (constref spline_ind       :TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  if show_spline then
    begin
      FilSplineRctEds(spline_ind);
      FilSplineRctPts(spline_ind);
      FilSplineEds   (spline_ind);
      FilSplinePts   (spline_ind);
    end;
end; {$endregion}
procedure TCurve.FilSplineAll      (constref start_ind,end_ind:TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i,j: integer;
begin
  if show_spline then
    for i:=0 to sln_obj_cnt-1 do
      begin
        j:=obj_var.obj_arr[obj_var.curve_inds_obj_arr[i]].t_ind;
        if (j>=start_ind) and (j<=end_ind) then
          FilSplineObj(i);
      end;
end; {$endregion}
procedure TCurve.FmlSplineInit;                                                                                                                     inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  FmlSplineObj[0]:=@Cycloid;
  FmlSplineObj[1]:=@Epicycloid;
  FmlSplineObj[2]:=@Rose;
  FmlSplineObj[3]:=@Spiral;
  FmlSplineObj[4]:=@Superellipse;
end; {$endregion}
procedure TCurve.FmlSplinePrev     (constref fml_pts_cnt      :TColor);                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rct       : TPtRect;
  color_info: TColorInfo;
begin
  if down_play_anim_ptr^ then
    Exit;
  with srf_var,sln_var,global_prop do
    begin
      sln_pts_cnt_add:=fml_pts_cnt;
      with PtRct(tex_var.tex_bmp_rct_pts) do
        FmlSplineObj[cur_tlt_dwn_btn_ind](world_axis.x+srf_var.world_axis_shift.x,
                                          world_axis.y+srf_var.world_axis_shift.y);
      sln_pts_cnt_add:=0;
      LowerBmpToMainBmp;
      color_info:=Default(TColorInfo);
      SetColorInfo(SetColorInv(clRed),color_info);
      with inn_wnd_rct do
        rct:=PtRct(left,top,right-1,bottom-1);
      LineABCG
      (
        fml_pts,
        0,
        fml_pts_cnt-1,
        srf_bmp_ptr,
        srf_bmp.width,
        color_info,
        rct,
        PtPos(0,0),
        cnc_ends and (fml_pts_cnt>2)
      );
      if show_collider then
        begin
          SetColorInfo(clBlue,color_info);
          LineABCE
          (
            fml_pts,
            0,
            fml_pts_cnt-1,
            srf_bmp_ptr,
            srf_bmp.width,
            color_info,
            rct,
            PtPos(0,0),
            10,
            cnc_ends and (fml_pts_cnt>2)
          );
        end;
      if world_axis_draw then
        WorldAxisDraw;
      CnvToCnv(srf_bmp_rct,F_MainForm.Canvas,srf_bmp.Canvas,SRCCOPY);
    end;
end; {$endregion}
procedure TCurve.Cycloid           (constref x,y              :integer);                                                                            inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  fml_pts_ptr: PPtPosF;
  dt         : double;
  j          : integer;
  n          : integer=0;
  t          : double =0.0;
  a          : double =0.0;
begin
  with global_prop do
    begin
      if (sln_pts_cnt_add=0) then
        Exit;
      case cycloid_dir_x of
        mdLeft :
          begin
            case cycloid_dir_y of
              mdUp:
                begin
                  a:=-cycloid_loop_rad/pi;
                  n:=(cycloid_loop_cnt<<1);
                end;
              mdDown:
                begin
                  a:=  cycloid_loop_rad/pi;
                  n:=-(cycloid_loop_cnt<<1);
                end;
            end;
          end;
        mdRight:
          begin
            case cycloid_dir_y of
              mdUp:
                begin
                  a:=- cycloid_loop_rad/pi;
                  n:=-(cycloid_loop_cnt<<1);
                end;
              mdDown:
                begin
                  a:= cycloid_loop_rad/pi;
                  n:=(cycloid_loop_cnt<<1);
                end;
            end;
          end;
      end;
      dt         :=n*pi/sln_pts_cnt_add;
      fml_pts_ptr:=Unaligned(@fml_pts[0]);
      for j:=0 to sln_pts_cnt_add-1 do
        begin
          fml_pts_ptr^.x:=x+a*(t-sin(t*cycloid_curvature)){x+a*sin(t) - circle};
          fml_pts_ptr^.y:=y+a*(1-cos(t*cycloid_curvature)){y+a*cos(t) - circle};
          Inc(fml_pts_ptr);
          t+=dt;
        end;
    end;
end; {$endregion}
procedure TCurve.Epicycloid        (constref x,y              :integer);                                                                            inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  fml_pts_ptr   : PPtPosF;
  t0,t1,t2,t3,dt: double;
  j,k           : integer;
begin
  with global_prop do
    begin
      if (sln_pts_cnt_add=0) then
        Exit;
      dt         :=epicycloid_angle*FULL_ROT/sln_pts_cnt_add;
      case fml_type of
        (sfEpicycloid ): k:=epicycloid_petals_cnt+1;
        (sfHypocycloid): k:=epicycloid_petals_cnt-1;
      end;
      t0         :=epicycloid_rad*0.1;
      t1         :=epicycloid_rot;
      t2         :=epicycloid_rot;
      t3         :=dt*k;
      fml_pts_ptr:=Unaligned(@fml_pts[0]);
      case fml_type of
        (sfEpicycloid):
          for j:=0 to sln_pts_cnt_add-1 do
            begin
              fml_pts_ptr^.x:=x+t0*(k*cos(t1)-cos(t2));
              fml_pts_ptr^.y:=y+t0*(k*sin(t1)-sin(t2));
              Inc(fml_pts_ptr);
              t1+=dt;
              t2+=t3;
            end;
        (sfHypocycloid):
          for j:=0 to sln_pts_cnt_add-1 do
            begin
              fml_pts_ptr^.x:=x+t0*(k*cos(t1)+cos(t2));{t0*((100-64)*cos(t1)+k*cos((100-64/64)*t1))}
              fml_pts_ptr^.y:=y+t0*(k*sin(t1)-sin(t2));{t0*((100-64)*sin(t1)-k*sin((100-64/64)*t1))}
              Inc(fml_pts_ptr);
              t1+=dt;
              t2+=t3;
            end;
      end;
    end;
end; {$endregion}
procedure TCurve.Rose              (constref x,y              :integer);                                                                            inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  fml_pts_ptr   : PPtPosF;
  t0,t1,t2,t3,dt: double;
  k             : double=3/1;
  j             : integer;
begin
  with global_prop do
    begin
      if (sln_pts_cnt_add=0) then
        Exit;
      dt         :=rose_angle*FULL_ROT/sln_pts_cnt_add;
      t0         :=rose_rad{*0.1};
      t1         :=rose_rot;
      t2         :=rose_rot;
      t3         :=dt*rose_petals_cnt;
      fml_pts_ptr:=Unaligned(@fml_pts[0]);
      for j:=0 to sln_pts_cnt_add-1 do
        begin
          fml_pts_ptr^.x:=x+t0*sin(rose_petals_cnt*t1)*cos(t1);
          fml_pts_ptr^.y:=y+t0*sin(rose_petals_cnt*t1)*sin(t1);
          Inc(fml_pts_ptr);
          t1+=dt;
        end;
    end;
end; {$endregion}
procedure TCurve.Spiral            (constref x,y              :integer);                                                                            inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  fml_pts_ptr: PPtPosF;
  t1,t2,t3,dt: double;
  j,k        : integer;
  n          : integer=2;
  t          : double;
  a          : double=10;
  b          : double=80{30};
begin
  with global_prop do
    begin
      if (sln_pts_cnt_add=0) then
        Exit;
      {n             :=8{8}; // count of loops;
      a              :={+}-8;   // direction of curve;
      fml_pts_ptr:=Unaligned(@fml_pts[0]);
      for i:=0 to sln_pts_cnt_add-1 do
        begin
          //t:=(n*pi*i)/(sln_pts_cnt_add);

          fml_pts_ptr^.x:=x+a*(cos(t)+t*sin(t));
          fml_pts_ptr^.y:=y+a*(sin(t)-t*cos(t));
          Inc(fml_pts_ptr);
        end;}
    end;
end; {$endregion}
procedure TCurve.Superellipse      (constref x,y              :integer);                                                                            inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  fml_pts_ptr: PPtPosF;
  t1,t2,t3,dt: double;
  j,k        : integer;
begin

end; {$endregion}
procedure TCurve.MovSplineRctEds   (constref spline_ind       :TColor; constref rct_dst:TPtRect);                                                   inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
begin
  with rct_eds_img_arr[spline_ind],local_prop do
    begin
      MDCalc(rct_ent,srf_var.mov_dir,srf_var.parallax_shift);
      if (rct_eds_show and (not IsRct1OutOfRct2(rct_ent,rct_dst))) then
        begin

          {Misc. Precalc.------------------------------------------------------------} {$region -fold}
          obj_arr_ptr:=@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]];
          SetBkgnd
          (
            obj_arr_ptr^.bkgnd_ptr,
            obj_arr_ptr^.bkgnd_width,
            obj_arr_ptr^.bkgnd_height
          ); {$endregion}

          {Drawing Of Spline Object Edges Bounding Rectangle-------------------------} {$region -fold}
          Rectangle
          (
            pts_rct_width__half-pts_rct_width__odd+rct_ent.left,
            pts_rct_height_half-pts_rct_height_odd+rct_ent.top ,
            bmp_dst_ptr,
            bmp_dst_width,
            bmp_dst_height,
            rct_dst,
            local_prop
          ); {$endregion}

        end;
    end;
end; {$endregion}
procedure TCurve.MovSplineRctPts   (constref spline_ind       :TColor; constref rct_dst:TPtRect);                                                   inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
begin
  with rct_pts_img_arr[spline_ind],local_prop do
    begin
      MDCalc(rct_ent,srf_var.mov_dir,srf_var.parallax_shift);
      if (rct_pts_show and (not IsRct1OutOfRct2(rct_ent,rct_dst))) then
        begin

          {Misc. Precalc.------------------------------------------------------------} {$region -fold}
          obj_arr_ptr:=@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]];
          SetBkgnd
          (
            obj_arr_ptr^.bkgnd_ptr,
            obj_arr_ptr^.bkgnd_width,
            obj_arr_ptr^.bkgnd_height
          ); {$endregion}

          {Drawing Of Spline Object Edges Bounding Rectangle-------------------------} {$region -fold}
          Rectangle
          (
            pts_rct_width__half-pts_rct_width__odd+rct_ent.left,
            pts_rct_height_half-pts_rct_height_odd+rct_ent.top ,
            bmp_dst_ptr,
            bmp_dst_width,
            bmp_dst_height,
            rct_dst,
            local_prop
          ); {$endregion}

        end;
    end;
end; {$endregion}
procedure TCurve.MovSplineEds0     (constref spline_ind       :TColor; constref rct_dst:TPtRect);                                                   inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr    : PObjInfo;
  sln_pts_ptr    : PPtPosF;
  rct            : TPtRect;
  x0,y0,x1,y1,b,i: integer;
begin
  with eds_img_arr[spline_ind],local_prop do
    begin
      MDCalc(rct_ent,srf_var.mov_dir,srf_var.parallax_shift);
      if (eds_show and (not IsRct1OutOfRct2(rct_ent,rct_dst))) then
        begin

          {Misc. Precalc.------------------------------------------------------------} {$region -fold}
          rct        :=PtRct(rct_dst.left  +0,
                             rct_dst.top   +0,
                             rct_dst.right -1,
                             rct_dst.bottom-1);
          b          :=partial_pts_sum[spline_ind];
          obj_arr_ptr:=@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]];
          SetBkgnd
          (
            obj_arr_ptr^.bkgnd_ptr,
            obj_arr_ptr^.bkgnd_width,
            obj_arr_ptr^.bkgnd_height
          ); {$endregion}

          case eds_width of
            1:
              begin

                {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
                if cnc_ends then
                  ClippedLine1
                  (
                    Trunc(sln_pts[b+00000000000000000000000000000].x)+srf_var.world_axis_shift.x,
                    Trunc(sln_pts[b+00000000000000000000000000000].y)+srf_var.world_axis_shift.y,
                    Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+srf_var.world_axis_shift.x,
                    Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+srf_var.world_axis_shift.y,
                    rct,
                    Unaligned(@LinePHL  ),
                    Unaligned(@LinePHL30),
                    Unaligned(@LineSHL30)
                  ); {$endregion}

                {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
                sln_pts_ptr:=Unaligned(@sln_pts[b]);
                for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
                  begin
                    ClippedLine1
                    (
                      Trunc((sln_pts_ptr+0)^.x)+srf_var.world_axis_shift.x,
                      Trunc((sln_pts_ptr+0)^.y)+srf_var.world_axis_shift.y,
                      Trunc((sln_pts_ptr+1)^.x)+srf_var.world_axis_shift.x,
                      Trunc((sln_pts_ptr+1)^.y)+srf_var.world_axis_shift.y,
                      rct,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL30),
                      Unaligned(@LineSHL30)
                    );
                    Inc(sln_pts_ptr);
                  end; {$endregion}

              end;

            2:
              begin

                {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
                if cnc_ends then
                  begin
                    x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+srf_var.world_axis_shift.x;
                    y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+srf_var.world_axis_shift.y;
                    x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+srf_var.world_axis_shift.x;
                    y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+srf_var.world_axis_shift.y;
                    ClippedLine1
                    (
                      x0,
                      y0,
                      x1,
                      y1,
                      rct,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL30),
                      Unaligned(@LineSHL30)
                    );
                    if (Abs(y1-y0)<Abs(x1-x0)) then
                      ClippedLine1
                      (
                        x0+0,
                        y0+1,
                        x1+0,
                        y1+1,
                        rct,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL30),
                        Unaligned(@LineSHL30)
                      )
                    else
                      ClippedLine1
                      (
                        x0+1,
                        y0+0,
                        x1+1,
                        y1+0,
                        rct,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL30),
                        Unaligned(@LineSHL30)
                      )
                  end; {$endregion}

                {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
                sln_pts_ptr:=Unaligned(@sln_pts[b]);
                for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
                  begin
                    x0:=Trunc((sln_pts_ptr+0)^.x)+srf_var.world_axis_shift.x;
                    y0:=Trunc((sln_pts_ptr+0)^.y)+srf_var.world_axis_shift.y;
                    x1:=Trunc((sln_pts_ptr+1)^.x)+srf_var.world_axis_shift.x;
                    y1:=Trunc((sln_pts_ptr+1)^.y)+srf_var.world_axis_shift.y;
                    ClippedLine1
                    (
                      x0,
                      y0,
                      x1,
                      y1,
                      rct,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL30),
                      Unaligned(@LineSHL30)
                    );
                    if (Abs(y1-y0)<Abs(x1-x0)) then
                      ClippedLine1
                      (
                        x0+0,
                        y0+1,
                        x1+0,
                        y1+1,
                        rct,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL30),
                        Unaligned(@LineSHL30)
                      )
                    else
                      ClippedLine1
                      (
                        x0+1,
                        y0+0,
                        x1+1,
                        y1+0,
                        rct,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL30),
                        Unaligned(@LineSHL30)
                      );
                    Inc(sln_pts_ptr);
                  end; {$endregion}

              end;
            3:
              begin

                {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
                if cnc_ends then
                  begin
                    x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+srf_var.world_axis_shift.x;
                    y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+srf_var.world_axis_shift.y;
                    x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+srf_var.world_axis_shift.x;
                    y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+srf_var.world_axis_shift.y;
                    ClippedLine1
                    (
                      x0,
                      y0,
                      x1,
                      y1,
                      rct,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL30),
                      Unaligned(@LineSHL30)
                    );
                    if (Abs(y1-y0)<Abs(x1-x0)) then
                      begin
                        ClippedLine1
                        (
                          x0+0,
                          y0+1,
                          x1+0,
                          y1+1,
                          rct,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        );
                        ClippedLine1
                        (
                          x0+0,
                          y0-1,
                          x1+0,
                          y1-1,
                          rct,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        );
                      end
                    else
                      begin
                        ClippedLine1
                        (
                          x0+1,
                          y0+0,
                          x1+1,
                          y1+0,
                          rct,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        );
                        ClippedLine1
                        (
                          x0-1,
                          y0+0,
                          x1-1,
                          y1+0,
                          rct,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        );
                      end;
                  end; {$endregion}

                {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
                sln_pts_ptr:=Unaligned(@sln_pts[b]);
                for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
                  begin
                    x0:=Trunc((sln_pts_ptr+0)^.x)+srf_var.world_axis_shift.x;
                    y0:=Trunc((sln_pts_ptr+0)^.y)+srf_var.world_axis_shift.y;
                    x1:=Trunc((sln_pts_ptr+1)^.x)+srf_var.world_axis_shift.x;
                    y1:=Trunc((sln_pts_ptr+1)^.y)+srf_var.world_axis_shift.y;
                    ClippedLine1
                    (
                      x0,
                      y0,
                      x1,
                      y1,
                      rct,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL30),
                      Unaligned(@LineSHL30)
                    );
                    if (Abs(y1-y0)<Abs(x1-x0)) then
                      begin
                        ClippedLine1
                        (
                          x0+0,
                          y0+1,
                          x1+0,
                          y1+1,
                          rct,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        );
                        ClippedLine1
                        (
                          x0+0,
                          y0-1,
                          x1+0,
                          y1-1,
                          rct,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        );
                      end
                    else
                      begin
                        ClippedLine1
                        (
                          x0+1,
                          y0+0,
                          x1+1,
                          y1+0,
                          rct,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        );
                        ClippedLine1
                        (
                          x0-1,
                          y0+0,
                          x1-1,
                          y1+0,
                          rct,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        );
                      end;
                    Inc(sln_pts_ptr);
                  end; {$endregion}

              end;
          end;

        end;
    end;
end; {$endregion}
procedure TCurve.MovSplineEds1     (constref spline_ind       :TColor; constref rct_dst:TPtRect);                                                   inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr    : PObjInfo;
  sln_pts_ptr    : PPtPosF;
  rct            : TPtRect;
  x0,y0,x1,y1,b,i: integer;
begin
  with eds_img_arr[spline_ind],local_prop do
    begin
      MDCalc(rct_ent,srf_var.mov_dir,srf_var.parallax_shift);
      if (eds_show and (not IsRct1OutOfRct2(rct_ent,rct_dst))) then
        begin

          {Misc. Precalc.------------------------------------------------------------} {$region -fold}
          rct        :=PtRct(rct_dst.left  +0,
                             rct_dst.top   +0,
                             rct_dst.right -1,
                             rct_dst.bottom-1);
          b          :=partial_pts_sum[spline_ind];
          obj_arr_ptr:=@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]];
          SetBkgnd
          (
            obj_arr_ptr^.bkgnd_ptr,
            obj_arr_ptr^.bkgnd_width,
            obj_arr_ptr^.bkgnd_height
          ); {$endregion}

          case eds_width of
            1:
              begin

                {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
                if (not (sel_var.is_point_selected[b+00000000000000000000000000000] or
                         sel_var.is_point_selected[b+sln_obj_pts_cnt[spline_ind]-1])) then
                  if cnc_ends then
                    ClippedLine1
                    (
                      Trunc(sln_pts[b+00000000000000000000000000000].x)+srf_var.world_axis_shift.x,
                      Trunc(sln_pts[b+00000000000000000000000000000].y)+srf_var.world_axis_shift.y,
                      Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+srf_var.world_axis_shift.x,
                      Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+srf_var.world_axis_shift.y,
                      rct,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL30),
                      Unaligned(@LineSHL30)
                    ); {$endregion}

                {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
                sln_pts_ptr:=Unaligned(@sln_pts[b]);
                for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
                  begin
                    if (not (sel_var.is_point_selected[b+i] or
                             sel_var.is_point_selected[b+i+1])) then
                      ClippedLine1
                      (
                        Trunc((sln_pts_ptr+0)^.x)+srf_var.world_axis_shift.x,
                        Trunc((sln_pts_ptr+0)^.y)+srf_var.world_axis_shift.y,
                        Trunc((sln_pts_ptr+1)^.x)+srf_var.world_axis_shift.x,
                        Trunc((sln_pts_ptr+1)^.y)+srf_var.world_axis_shift.y,
                        rct,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL30),
                        Unaligned(@LineSHL30)
                      );
                    Inc(sln_pts_ptr);
                  end; {$endregion}

              end;

            2:
              begin

                {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
                if (not (sel_var.is_point_selected[b+00000000000000000000000000000] or
                         sel_var.is_point_selected[b+sln_obj_pts_cnt[spline_ind]-1])) then
                  if cnc_ends then
                    begin
                      x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+srf_var.world_axis_shift.x;
                      y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+srf_var.world_axis_shift.y;
                      x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+srf_var.world_axis_shift.x;
                      y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+srf_var.world_axis_shift.y;
                      ClippedLine1
                      (
                        x0,
                        y0,
                        x1,
                        y1,
                        rct,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL30),
                        Unaligned(@LineSHL30)
                      );
                      if (Abs(y1-y0)<Abs(x1-x0)) then
                        ClippedLine1
                        (
                          x0+0,
                          y0+1,
                          x1+0,
                          y1+1,
                          rct,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        )
                      else
                        ClippedLine1
                        (
                          x0+1,
                          y0+0,
                          x1+1,
                          y1+0,
                          rct,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        )
                    end; {$endregion}

                {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
                sln_pts_ptr:=Unaligned(@sln_pts[b]);
                for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
                  begin
                    if (not (sel_var.is_point_selected[b+i] or
                             sel_var.is_point_selected[b+i+1])) then
                      begin
                        x0:=Trunc((sln_pts_ptr+0)^.x)+srf_var.world_axis_shift.x;
                        y0:=Trunc((sln_pts_ptr+0)^.y)+srf_var.world_axis_shift.y;
                        x1:=Trunc((sln_pts_ptr+1)^.x)+srf_var.world_axis_shift.x;
                        y1:=Trunc((sln_pts_ptr+1)^.y)+srf_var.world_axis_shift.y;
                        ClippedLine1
                        (
                          x0,
                          y0,
                          x1,
                          y1,
                          rct,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        );
                        if (Abs(y1-y0)<Abs(x1-x0)) then
                          ClippedLine1
                          (
                            x0+0,
                            y0+1,
                            x1+0,
                            y1+1,
                            rct,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL30),
                            Unaligned(@LineSHL30)
                          )
                        else
                          ClippedLine1
                          (
                            x0+1,
                            y0+0,
                            x1+1,
                            y1+0,
                            rct,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL30),
                            Unaligned(@LineSHL30)
                          );
                      end;
                    Inc(sln_pts_ptr);
                  end; {$endregion}

              end;
            3:
              begin

                {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
                if (not (sel_var.is_point_selected[b+00000000000000000000000000000] or
                         sel_var.is_point_selected[b+sln_obj_pts_cnt[spline_ind]-1])) then
                  if cnc_ends then
                    begin
                      x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+srf_var.world_axis_shift.x;
                      y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+srf_var.world_axis_shift.y;
                      x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+srf_var.world_axis_shift.x;
                      y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+srf_var.world_axis_shift.y;
                      ClippedLine1
                      (
                        x0,
                        y0,
                        x1,
                        y1,
                        rct,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL30),
                        Unaligned(@LineSHL30)
                      );
                      if (Abs(y1-y0)<Abs(x1-x0)) then
                        begin
                          ClippedLine1
                          (
                            x0+0,
                            y0+1,
                            x1+0,
                            y1+1,
                            rct,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL30),
                            Unaligned(@LineSHL30)
                          );
                          ClippedLine1
                          (
                            x0+0,
                            y0-1,
                            x1+0,
                            y1-1,
                            rct,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL30),
                            Unaligned(@LineSHL30)
                          );
                        end
                      else
                        begin
                          ClippedLine1
                          (
                            x0+1,
                            y0+0,
                            x1+1,
                            y1+0,
                            rct,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL30),
                            Unaligned(@LineSHL30)
                          );
                          ClippedLine1
                          (
                            x0-1,
                            y0+0,
                            x1-1,
                            y1+0,
                            rct,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL30),
                            Unaligned(@LineSHL30)
                          );
                        end;
                    end; {$endregion}

                {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
                sln_pts_ptr:=Unaligned(@sln_pts[b]);
                for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
                  begin
                    if (not (sel_var.is_point_selected[b+i] or
                             sel_var.is_point_selected[b+i+1])) then
                      begin
                        x0:=Trunc((sln_pts_ptr+0)^.x)+srf_var.world_axis_shift.x;
                        y0:=Trunc((sln_pts_ptr+0)^.y)+srf_var.world_axis_shift.y;
                        x1:=Trunc((sln_pts_ptr+1)^.x)+srf_var.world_axis_shift.x;
                        y1:=Trunc((sln_pts_ptr+1)^.y)+srf_var.world_axis_shift.y;
                        ClippedLine1
                        (
                          x0,
                          y0,
                          x1,
                          y1,
                          rct,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        );
                        if (Abs(y1-y0)<Abs(x1-x0)) then
                          begin
                            ClippedLine1
                            (
                              x0+0,
                              y0+1,
                              x1+0,
                              y1+1,
                              rct,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL30),
                              Unaligned(@LineSHL30)
                            );
                            ClippedLine1
                            (
                              x0+0,
                              y0-1,
                              x1+0,
                              y1-1,
                              rct,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL30),
                              Unaligned(@LineSHL30)
                            );
                          end
                        else
                          begin
                            ClippedLine1
                            (
                              x0+1,
                              y0+0,
                              x1+1,
                              y1+0,
                              rct,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL30),
                              Unaligned(@LineSHL30)
                            );
                            ClippedLine1
                            (
                              x0-1,
                              y0+0,
                              x1-1,
                              y1+0,
                              rct,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL30),
                              Unaligned(@LineSHL30)
                            );
                          end;
                      end;
                    Inc(sln_pts_ptr);
                  end; {$endregion}

              end;
          end;

        end;
    end;
end; {$endregion}
procedure TCurve.MovSplineEds2     (constref spline_ind       :TColor; constref rct_dst:TPtRect);                                                   inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr    : PObjInfo;
  sln_pts_ptr    : PPtPosF;
  useless_arr_ptr: PByte;
  rct            : TPtRect;
  x0,y0,x1,y1,b,i: integer;
begin
  with eds_img_arr[spline_ind],local_prop do
    begin
      MDCalc(rct_ent,srf_var.mov_dir,srf_var.parallax_shift);
      if (eds_show and (not IsRct1OutOfRct2(rct_ent,rct_dst))) then
        begin

          {Misc. Precalc.------------------------------------------------------------} {$region -fold}
          rct        :=PtRct(rct_dst.left  +0,
                             rct_dst.top   +0,
                             rct_dst.right -1,
                             rct_dst.bottom-1);
          b          :=partial_pts_sum[spline_ind];
          obj_arr_ptr:=@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]];
          SetBkgnd
          (
            obj_arr_ptr^.bkgnd_ptr,
            obj_arr_ptr^.bkgnd_width,
            obj_arr_ptr^.bkgnd_height
          ); {$endregion}

          case eds_width of
            1:
              begin

                {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
                if cnc_ends then
                  ClippedLine1
                  (
                    Trunc(sln_pts[b+00000000000000000000000000000].x)+srf_var.world_axis_shift.x,
                    Trunc(sln_pts[b+00000000000000000000000000000].y)+srf_var.world_axis_shift.y,
                    Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+srf_var.world_axis_shift.x,
                    Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+srf_var.world_axis_shift.y,
                    rct,
                    Unaligned(@LinePHL  ),
                    Unaligned(@LinePHL30),
                    Unaligned(@LineSHL30)
                  ); {$endregion}

                {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
                useless_arr_ptr:=Unaligned(@useless_arr[0]);
                sln_pts_ptr    :=Unaligned(@sln_pts    [b]);
                for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
                  begin
                    if (useless_arr_ptr^=1) then
                      ClippedLine1
                      (
                        Trunc((sln_pts_ptr+0)^.x)+srf_var.world_axis_shift.x,
                        Trunc((sln_pts_ptr+0)^.y)+srf_var.world_axis_shift.y,
                        Trunc((sln_pts_ptr+1)^.x)+srf_var.world_axis_shift.x,
                        Trunc((sln_pts_ptr+1)^.y)+srf_var.world_axis_shift.y,
                        rct,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL30),
                        Unaligned(@LineSHL30)
                      );
                    Inc(useless_arr_ptr);
                    Inc(sln_pts_ptr);
                  end; {$endregion}

              end;

            2:
              begin

                {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
                if cnc_ends then
                  begin
                    x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+srf_var.world_axis_shift.x;
                    y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+srf_var.world_axis_shift.y;
                    x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+srf_var.world_axis_shift.x;
                    y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+srf_var.world_axis_shift.y;
                    ClippedLine1
                    (
                      x0,
                      y0,
                      x1,
                      y1,
                      rct,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL30),
                      Unaligned(@LineSHL30)
                    );
                    if (Abs(y1-y0)<Abs(x1-x0)) then
                      ClippedLine1
                      (
                        x0+0,
                        y0+1,
                        x1+0,
                        y1+1,
                        rct,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL30),
                        Unaligned(@LineSHL30)
                      )
                    else
                      ClippedLine1
                      (
                        x0+1,
                        y0+0,
                        x1+1,
                        y1+0,
                        rct,
                        Unaligned(@LinePHL  ),
                        Unaligned(@LinePHL30),
                        Unaligned(@LineSHL30)
                      )
                  end; {$endregion}

                {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
                useless_arr_ptr:=Unaligned(@useless_arr[0]);
                sln_pts_ptr    :=Unaligned(@sln_pts    [b]);
                for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
                  begin
                    if (useless_arr_ptr^=1) then
                      begin
                        x0:=Trunc((sln_pts_ptr+0)^.x)+srf_var.world_axis_shift.x;
                        y0:=Trunc((sln_pts_ptr+0)^.y)+srf_var.world_axis_shift.y;
                        x1:=Trunc((sln_pts_ptr+1)^.x)+srf_var.world_axis_shift.x;
                        y1:=Trunc((sln_pts_ptr+1)^.y)+srf_var.world_axis_shift.y;
                        ClippedLine1
                        (
                          x0,
                          y0,
                          x1,
                          y1,
                          rct,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        );
                        if (Abs(y1-y0)<Abs(x1-x0)) then
                          ClippedLine1
                          (
                            x0+0,
                            y0+1,
                            x1+0,
                            y1+1,
                            rct,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL30),
                            Unaligned(@LineSHL30)
                          )
                        else
                          ClippedLine1
                          (
                            x0+1,
                            y0+0,
                            x1+1,
                            y1+0,
                            rct,
                            Unaligned(@LinePHL  ),
                            Unaligned(@LinePHL30),
                            Unaligned(@LineSHL30)
                          );
                      end;
                    Inc(useless_arr_ptr);
                    Inc(sln_pts_ptr);
                  end; {$endregion}

              end;
            3:
              begin

                {Drawing Of Connected Edges(Between First And Last Points Of Spline Object)} {$region -fold}
                if cnc_ends then
                  begin
                    x0:=Trunc(sln_pts[b+00000000000000000000000000000].x)+srf_var.world_axis_shift.x;
                    y0:=Trunc(sln_pts[b+00000000000000000000000000000].y)+srf_var.world_axis_shift.y;
                    x1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].x)+srf_var.world_axis_shift.x;
                    y1:=Trunc(sln_pts[b+sln_obj_pts_cnt[spline_ind]-1].y)+srf_var.world_axis_shift.y;
                    ClippedLine1
                    (
                      x0,
                      y0,
                      x1,
                      y1,
                      rct,
                      Unaligned(@LinePHL  ),
                      Unaligned(@LinePHL30),
                      Unaligned(@LineSHL30)
                    );
                    if (Abs(y1-y0)<Abs(x1-x0)) then
                      begin
                        ClippedLine1
                        (
                          x0+0,
                          y0+1,
                          x1+0,
                          y1+1,
                          rct,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        );
                        ClippedLine1
                        (
                          x0+0,
                          y0-1,
                          x1+0,
                          y1-1,
                          rct,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        );
                      end
                    else
                      begin
                        ClippedLine1
                        (
                          x0+1,
                          y0+0,
                          x1+1,
                          y1+0,
                          rct,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        );
                        ClippedLine1
                        (
                          x0-1,
                          y0+0,
                          x1-1,
                          y1+0,
                          rct,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        );
                      end;
                  end; {$endregion}

                {Drawing Of Spline Object Edges--------------------------------------------} {$region -fold}
                useless_arr_ptr:=Unaligned(@useless_arr[0]);
                sln_pts_ptr    :=Unaligned(@sln_pts    [b]);
                for i:=0 to sln_obj_pts_cnt[spline_ind]-2 do
                  begin
                    if (useless_arr_ptr^=1) then
                      begin
                        x0:=Trunc((sln_pts_ptr+0)^.x)+srf_var.world_axis_shift.x;
                        y0:=Trunc((sln_pts_ptr+0)^.y)+srf_var.world_axis_shift.y;
                        x1:=Trunc((sln_pts_ptr+1)^.x)+srf_var.world_axis_shift.x;
                        y1:=Trunc((sln_pts_ptr+1)^.y)+srf_var.world_axis_shift.y;
                        ClippedLine1
                        (
                          x0,
                          y0,
                          x1,
                          y1,
                          rct,
                          Unaligned(@LinePHL  ),
                          Unaligned(@LinePHL30),
                          Unaligned(@LineSHL30)
                        );
                        if (Abs(y1-y0)<Abs(x1-x0)) then
                          begin
                            ClippedLine1
                            (
                              x0+0,
                              y0+1,
                              x1+0,
                              y1+1,
                              rct,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL30),
                              Unaligned(@LineSHL30)
                            );
                            ClippedLine1
                            (
                              x0+0,
                              y0-1,
                              x1+0,
                              y1-1,
                              rct,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL30),
                              Unaligned(@LineSHL30)
                            );
                          end
                        else
                          begin
                            ClippedLine1
                            (
                              x0+1,
                              y0+0,
                              x1+1,
                              y1+0,
                              rct,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL30),
                              Unaligned(@LineSHL30)
                            );
                            ClippedLine1
                            (
                              x0-1,
                              y0+0,
                              x1-1,
                              y1+0,
                              rct,
                              Unaligned(@LinePHL  ),
                              Unaligned(@LinePHL30),
                              Unaligned(@LineSHL30)
                            );
                          end;
                      end;
                    Inc(useless_arr_ptr);
                    Inc(sln_pts_ptr);
                  end; {$endregion}

              end;
          end;

        end;
    end;
end; {$endregion}
procedure TCurve.MovSplinePts0     (constref spline_ind       :TColor; constref rct_dst:TPtRect);                                                   inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
  sln_pts_ptr: PPtPosF;
  b,i        : integer;
begin
  with pts_img_arr[spline_ind],local_prop do
    begin
      MDCalc(rct_ent,srf_var.mov_dir,srf_var.parallax_shift);
      if (pts_show and (not IsRct1OutOfRct2(rct_ent,rct_dst))) then
        begin

          {Misc. Precalc.-----------------} {$region -fold}
          b          :=partial_pts_sum[spline_ind];
          obj_arr_ptr:=@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]];
          SetBkgnd
          (
            obj_arr_ptr^.bkgnd_ptr,
            obj_arr_ptr^.bkgnd_width,
            obj_arr_ptr^.bkgnd_height
          ); {$endregion}

          {Drawing Of Spline Object Points} {$region -fold}
          sln_pts_ptr:=Unaligned(@sln_pts[b]);
          for i:=0 to sln_obj_pts_cnt[spline_ind]-1 do
            begin
              Rectangle
              (
                Trunc(sln_pts_ptr^.x)+srf_var.world_axis_shift.x,
                Trunc(sln_pts_ptr^.y)+srf_var.world_axis_shift.y,
                bmp_dst_ptr,
                bmp_dst_width,
                bmp_dst_height,
                rct_dst,
                local_prop
              );
              Inc(sln_pts_ptr);
            end; {$endregion}

        end;
    end;
end; {$endregion}
procedure TCurve.MovSplinePts1     (constref spline_ind       :TColor; constref rct_dst:TPtRect);                                                   inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
  sln_pts_ptr: PPtPosF;
  b,i        : integer;
begin
  with pts_img_arr[spline_ind],local_prop do
    begin
      MDCalc(rct_ent,srf_var.mov_dir,srf_var.parallax_shift);
      if (pts_show and (not IsRct1OutOfRct2(rct_ent,rct_dst))) then
        begin

          {Misc. Precalc.-----------------} {$region -fold}
          b          :=partial_pts_sum[spline_ind];
          obj_arr_ptr:=@obj_var.obj_arr[obj_var.curve_inds_obj_arr[spline_ind]];
          SetBkgnd
          (
            obj_arr_ptr^.bkgnd_ptr,
            obj_arr_ptr^.bkgnd_width,
            obj_arr_ptr^.bkgnd_height
          ); {$endregion}

          {Drawing Of Spline Object Points} {$region -fold}
          sln_pts_ptr:=Unaligned(@sln_pts[b]);
          for i:=0 to sln_obj_pts_cnt[spline_ind]-1 do
            begin
              if (not sel_var.is_point_selected[b+i]) then
                Rectangle
                (
                  Trunc(sln_pts_ptr^.x)+srf_var.world_axis_shift.x,
                  Trunc(sln_pts_ptr^.y)+srf_var.world_axis_shift.y,
                  bmp_dst_ptr,
                  bmp_dst_width,
                  bmp_dst_height,
                  rct_dst,
                  local_prop
                );
              Inc(sln_pts_ptr);
            end; {$endregion}

        end;
    end;
end; {$endregion}
procedure TCurve.MovSplineObj      (constref spline_ind       :TColor; constref rct_dst:TPtRect);                                                   inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  MovSplineRctEds(spline_ind,rct_dst);
  MovSplineRctPts(spline_ind,rct_dst);
  if (has_sel_pts[spline_ind]=0) then
    begin
      if (not eds_img_arr[spline_ind].local_prop.hid_ln_elim) then
        MovSplineEds0(spline_ind,rct_dst)
      else
        MovSplineEds2(spline_ind,rct_dst);
      MovSplinePts0(spline_ind,rct_dst);
    end
  else
    begin
      MovSplineEds1(spline_ind,rct_dst);
      MovSplinePts1(spline_ind,rct_dst);
    end;
end; {$endregion}
procedure TCurve.MovSplineAll      (constref start_ind,end_ind:TColor; constref rct_dst:TPtRect);                                                   inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  for i:=start_ind to end_ind do
    begin
      MovSplineRctEds(i,rct_dst);
      MovSplineRctPts(i,rct_dst);
      if (has_sel_pts[i]=0) then
        begin
          if (not eds_img_arr[i].local_prop.hid_ln_elim) then
            MovSplineEds0(i,rct_dst)
          else
            MovSplineEds2(i,rct_dst);
          MovSplinePts0(i,rct_dst);
        end
      else
        begin
          MovSplineEds1(i,rct_dst);
          MovSplinePts1(i,rct_dst);
        end;
    end;
end; {$endregion}
procedure TCurve.RepSplineRctEds   (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with rct_eds_img_arr[spline_ind],local_prop do
    fst_img.ResNTValueArr(rct_eds_big_img.ln_arr1,
                          rct_eds_big_img.ln_arr_width);
end; {$endregion}
procedure TCurve.RepSplineRctPts   (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with rct_pts_img_arr[spline_ind],local_prop do
    fst_img.ResNTValueArr(rct_pts_big_img.ln_arr1,
                          rct_pts_big_img.ln_arr_width);
end; {$endregion}
procedure TCurve.RepSplineEds      (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with eds_img_arr[spline_ind],local_prop do
    fst_img.ResNTValueArr(eds_big_img.ln_arr1,
                          eds_big_img.ln_arr_width);
end; {$endregion}
procedure TCurve.RepSplinePts      (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with pts_img_arr[spline_ind],local_prop do
    fst_img.ResNTValueArr(pts_big_img.ln_arr1,
                          pts_big_img.ln_arr_width);
end; {$endregion}
procedure TCurve.RndSplineCol      (var      local_prop       :TCurveProp; var col,col_inv:TColor; var col_ptr:PInteger; constref btn:TSpeedButton);        {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with local_prop do
   begin
     col     :=Random($7FFFFFFF);
     col_inv :=SetColorInv(col);
     col_ptr :=@btn.Color;
     col_ptr^:=col;
     btn.Repaint;
   end;
end; {$endregion}
procedure TCurve.RndSplineObj      (constref pt               :TPtPos; constref w,h:TColor);                                                                {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sln_pts_add_ptr: PPtPosF;
  i,w_,h_        : integer;
begin
  Randomize;
  w_             :=pt.x-w>>1;
  h_             :=pt.y-h>>1;
  sln_pts_cnt_add:=global_prop.pts_cnt_val;
  Inc(sln_pts_cnt,sln_pts_cnt_add);
  SetLength(sln_pts_add,0);
  SetLength(sln_pts_add,sln_pts_cnt_add);
  sln_pts_add_ptr:=Unaligned(@sln_pts_add[0]);
  for i:=0 to sln_pts_cnt_add-1 do
    begin
      (sln_pts_add_ptr+i)^.x:=w_+Random(w);
      (sln_pts_add_ptr+i)^.y:=h_+Random(h);
    end;
end; {$endregion}
procedure TCurve.SmpSplineEds      (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure TCurve.SmpSplinePts      (constref spline_ind       :TColor);                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
var
  k1,k2        : double;
  i,m1,m2,m3,m4: integer;
begin
  {k1:=0;
  k2:=0;
  for i:=1 to sln_pts_cnt-2 do
    begin
      k1:=(sln_pts[i+1].y-sln_pts[i+0].y)/
          (sln_pts[i+1].x-sln_pts[i+0].x);
      k2:=(sln_pts[i+0].y-sln_pts[i-1].y)/
          (sln_pts[i+0].x-sln_pts[i-1].x);
      if (arctan(abs((k1-k2)/(1+(k1*k2))))< pi/2) and
         (arctan(abs((k1-k2)/(1+(k1*k2))))>=20*pi/Trunc(F_MainForm.FSE_Spline_Simplification_Angle.value)) then
        Windows.Rectangle(F_MainForm.Canvas.Handle,
                          Trunc(sln_pts[i].x)-2,
                          Trunc(sln_pts[i].y)-2,
                          Trunc(sln_pts[i].x)+3,
                          Trunc(sln_pts[i].y)+3);
    end;}
end; {$endregion}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.SB_SplineClick                                         (sender:TObject); {$region -fold}
begin
  DrawingPanelsSetVisibility1(down_spline_ptr,P_Spline,P_Draw_Custom_Panel,prev_panel_draw,curr_panel_draw);
  DrawingPanelsSetVisibility2;
end; {$endregion}
{Edges-------}
procedure TF_MainForm.P_Edges_PropMouseEnter                                 (sender:TObject); {$region -fold}
begin
  P_Edges_Prop.Color:=NAV_SEL_COL_1;
  //P_Edges_Prop.Width:=158;
end; {$endregion}
procedure TF_MainForm.P_Edges_PropMouseLeave                                 (sender:TObject); {$region -fold}
begin
  P_Edges_Prop.Color:=$00BAB5A3;
  //P_Edges_Prop.Width:=32;
end; {$endregion}
procedure TF_MainForm.CB_Spline_Edges_StyleSelect                            (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.eds_bld_stl:=TDrawingStyle(CB_Spline_Edges_Style.ItemIndex);
end; {$endregion}
procedure TF_MainForm.SB_Spline_Edges_ShowClick                              (sender:TObject); {$region -fold}
begin
  BtnColAndDown(SB_Spline_Edges_Show,sln_var.global_prop.eds_show);
end; {$endregion}
procedure TF_MainForm.SB_Spline_Edges_ColorClick                             (sender:TObject); {$region -fold}
begin
  CD_Select_Color.Color:=SB_Spline_Edges_Color.Color;
  CD_Select_Color.Execute;
  with sln_var.global_prop do
    begin
      eds_col    :=CD_Select_Color.Color;
      eds_col_inv:=SetColorInv(eds_col);
    end;
  SB_Spline_Edges_Color.Color:=CD_Select_Color.Color;
  SB_Spline_Edges_Color.Down :=False;
end; {$endregion}
procedure TF_MainForm.SB_Spline_Edges_Color_RandomClick                      (sender:TObject); {$region -fold}
begin
  BtnColAndDown(SB_Spline_Edges_Color_Random,sln_var.global_prop.eds_col_rnd);
end; {$endregion}
procedure TF_MainForm.SB_Spline_Edges_Color_FallOffClick                     (sender:TObject); {$region -fold}
begin
  BtnColAndDown(SB_Spline_Edges_Color_FallOff,sln_var.global_prop.eds_col_fall_off);
end; {$endregion}
procedure TF_MainForm.CB_Spline_Edges_Show_BoundsChange                      (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.rct_eds_show:=not sln_var.global_prop.rct_eds_show;
end; {$endregion}
procedure TF_MainForm.CB_Spline_Edges_ShapeSelect                            (sender:TObject); {$region -fold}
begin
  case CB_Spline_Edges_Shape.ItemIndex of
    0:
      begin
        L_Spline_Edges_Width         .Enabled:=True;
        SE_Spline_Edges_Width        .Enabled:=True;
        L_Spline_Edges_Dash_Length   .Enabled:=False;
        SE_Spline_Edges_Dash_Length  .Enabled:=False;
        L_Spline_Edges_Points_Radius .Enabled:=False;
        SE_Spline_Edges_Points_Radius.Enabled:=False;
      end;
    1:
      begin
        L_Spline_Edges_Width         .Enabled:=True;
        SE_Spline_Edges_Width        .Enabled:=True;
        L_Spline_Edges_Dash_Length   .Enabled:=True;
        SE_Spline_Edges_Dash_Length  .Enabled:=True;
        L_Spline_Edges_Points_Radius .Enabled:=False;
        SE_Spline_Edges_Points_Radius.Enabled:=False;
      end;
    2:
      begin
        L_Spline_Edges_Width         .Enabled:=False;
        SE_Spline_Edges_Width        .Enabled:=False;
        L_Spline_Edges_Dash_Length   .Enabled:=False;
        SE_Spline_Edges_Dash_Length  .Enabled:=False;
        L_Spline_Edges_Points_Radius .Enabled:=True;
        SE_Spline_Edges_Points_Radius.Enabled:=True;
      end;
  end;
end; {$endregion}
procedure TF_MainForm.P_Spline_EdgesMouseEnter                               (sender:TObject); {$region -fold}
begin
  P_Spline_Edges     .Color:=HighLight(P_Spline_Edges     .Color,0,0,0,0,0,16);
  P_Spline_Edges_Line.Color:=HighLight(P_Spline_Edges_Line.Color,0,0,0,0,0,16);
end; {$endregion}
procedure TF_MainForm.P_Spline_EdgesMouseLeave                               (sender:TObject); {$region -fold}
begin
  P_Spline_Edges     .Color:=Darken(P_Spline_Edges     .Color,0,0,0,0,0,16);
  P_Spline_Edges_Line.Color:=Darken(P_Spline_Edges_Line.Color,0,0,0,0,0,16);
end; {$endregion}
procedure TF_MainForm.CB_Spline_Edges_Anti_AliasingChange                    (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.eds_aa:=not sln_var.global_prop.eds_aa;
end; {$endregion}
procedure TF_MainForm.SE_Spline_Edges_WidthChange                            (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.eds_width:=SE_Spline_Edges_Width.value;
  SetEdsWidth(sln_var.global_prop);
end; {$endregion}
procedure TF_MainForm.CB_Spline_Connect_EndsChange                           (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.cnc_ends:=not sln_var.global_prop.cnc_ends;
end; {$endregion}
procedure TF_MainForm.CB_Spline_Invert_OrderChange                           (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.pts_ord_inv:=not sln_var.global_prop.pts_ord_inv;
end; {$endregion}
{Points------}
procedure TF_MainForm.P_Points_PropMouseEnter                                (sender:TObject); {$region -fold}
begin
  P_Points_Prop.Color:=NAV_SEL_COL_1;
end; {$endregion}
procedure TF_MainForm.P_Points_PropMouseLeave                                (sender:TObject); {$region -fold}
begin
  P_Points_Prop.Color:=$00BAB5A3;
end; {$endregion}
procedure TF_MainForm.CB_Spline_Points_StyleSelect                           (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.pts_bld_stl:=TDrawingStyle(CB_Spline_Points_Style.ItemIndex);
end; {$endregion}
procedure TF_MainForm.SB_Spline_Points_ShowClick                             (sender:TObject); {$region -fold}
begin
  BtnColAndDown(SB_Spline_Points_Show,sln_var.global_prop.pts_show);
end; {$endregion}
procedure TF_MainForm.SB_Spline_Points_ColorClick                            (sender:TObject); {$region -fold}
begin
  CD_Select_Color.Color:=SB_Spline_Points_Color.Color;
  CD_Select_Color.Execute;
  with sln_var.global_prop do
    begin
      pts_col    :=CD_Select_Color.Color;
      pts_col_inv:=SetColorInv(pts_col);
    end;
  SB_Spline_Points_Color.Color:=CD_Select_Color.Color;
  SB_Spline_Points_Color.Down :=False;
end; {$endregion}
procedure TF_MainForm.SB_Spline_Points_Color_RandomClick                     (sender:TObject); {$region -fold}
begin
  BtnColAndDown(SB_Spline_Points_Color_Random,sln_var.global_prop.pts_col_rnd);
end; {$endregion}
procedure TF_MainForm.SB_Spline_Points_Color_FallOffClick                    (sender:TObject); {$region -fold}
begin
  BtnColAndDown(SB_Spline_Points_Color_FallOff,sln_var.global_prop.pts_col_fall_off);
end; {$endregion}
procedure TF_MainForm.CB_Spline_Points_Show_BoundsChange                     (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.rct_pts_show:=not sln_var.global_prop.rct_pts_show;
end; {$endregion}
procedure TF_MainForm.CB_Spline_Points_ShapeSelect                           (sender:TObject); {$region -fold}
begin
  case CB_Spline_Points_Shape.ItemIndex of
    0:
      begin
        P_Spline_Points.Visible:=True;

      end;
    1:
      begin
        P_Spline_Points.Visible:=False;

      end;
    2:
      begin
        P_Spline_Points.Visible:=False;

      end;
    3:
      begin
        P_Spline_Points.Visible:=False;

      end;
  end;
end; {$endregion}
procedure TF_MainForm.P_Spline_PointsMouseEnter                              (sender:TObject); {$region -fold}
begin
  P_Spline_Points_Rectangle_Thickness      .Color:=HighLight(P_Spline_Points_Rectangle_Thickness      .Color,0,0,0,0,0,16);
  P_Spline_Points_Rectangle_Inner_Rectangle.Color:=HighLight(P_Spline_Points_Rectangle_Inner_Rectangle.Color,0,0,0,0,0,16);
  P_Spline_Points                          .Color:=HighLight(P_Spline_Points                          .Color,0,0,0,0,0,16);
end; {$endregion}
procedure TF_MainForm.P_Spline_PointsMouseLeave                              (sender:TObject); {$region -fold}
begin
  P_Spline_Points_Rectangle_Thickness      .Color:=Darken(P_Spline_Points_Rectangle_Thickness      .Color,0,0,0,0,0,16);
  P_Spline_Points_Rectangle_Inner_Rectangle.Color:=Darken(P_Spline_Points_Rectangle_Inner_Rectangle.Color,0,0,0,0,0,16);
  P_Spline_Points                          .Color:=Darken(P_Spline_Points                          .Color,0,0,0,0,0,16);
end; {$endregion}
procedure TF_MainForm.SE_Spline_Points_Rectangle_Thikness_LeftChange         (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.pts_rct_tns_left:=SE_Spline_Points_Rectangle_Thikness_Left.value;
  SetRctWidth (sln_var.global_prop);
  SetRctValues(sln_var.global_prop);
  SetRctDupId (sln_var.global_prop);
end; {$endregion}
procedure TF_MainForm.SE_Spline_Points_Rectangle_Thikness_TopChange          (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.pts_rct_tns_top:=SE_Spline_Points_Rectangle_Thikness_Top.value;
  SetRctHeight(sln_var.global_prop);
  SetRctValues(sln_var.global_prop);
  SetRctDupId (sln_var.global_prop);
end; {$endregion}
procedure TF_MainForm.SE_Spline_Points_Rectangle_Thikness_RightChange        (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.pts_rct_tns_right:=SE_Spline_Points_Rectangle_Thikness_Right.value;
  SetRctWidth (sln_var.global_prop);
  SetRctValues(sln_var.global_prop);
  SetRctDupId (sln_var.global_prop);
end; {$endregion}
procedure TF_MainForm.SE_Spline_Points_Rectangle_Thikness_BottomChange       (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.pts_rct_tns_bottom:=SE_Spline_Points_Rectangle_Thikness_Bottom.value;
  SetRctHeight(sln_var.global_prop);
  SetRctValues(sln_var.global_prop);
  SetRctDupId (sln_var.global_prop);
end; {$endregion}
procedure TF_MainForm.SE_Spline_Points_Rectangle_Inner_Rectangle_WidthChange (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.pts_rct_inn_width:=SE_Spline_Points_Rectangle_Inner_Rectangle_Width.value;
  SetRctWidth (sln_var.global_prop);
  SetRctValues(sln_var.global_prop);
  SetRctDupId (sln_var.global_prop);
end; {$endregion}
procedure TF_MainForm.SE_Spline_Points_Rectangle_Inner_Rectangle_HeightChange(sender:TObject); {$region -fold}
begin
  sln_var.global_prop.pts_rct_inn_height:=SE_Spline_Points_Rectangle_Inner_Rectangle_Height.value;
  SetRctHeight(sln_var.global_prop);
  SetRctValues(sln_var.global_prop);
  SetRctDupId (sln_var.global_prop);
end; {$endregion}
{Drawing-----}
function CycloidRangeCheck   : boolean;                                                        {$region -fold}
begin
  with sln_var,global_prop do
    begin
      if (cycloid_pts_cnt =0) or
         (cycloid_loop_cnt=0) or
         (cycloid_loop_rad=0) then
        with srf_var do
          begin
            LowerBmpToMainBmp;
            if world_axis_draw then
              WorldAxisDraw;
            CnvToCnv(srf_bmp_rct,F_MainForm.Canvas,srf_bmp.Canvas,SRCCOPY);
            Result:=True;
          end
      else
        Result:=False;
    end;
end; {$endregion}
function EpicycloidRangeCheck: boolean;                                                        {$region -fold}
begin
  with sln_var,global_prop do
    begin
      if ((fml_type=(sfEpicycloid )) and (epicycloid_petals_cnt=0)) or
         ((fml_type=(sfHypocycloid)) and (epicycloid_petals_cnt<3)) or
         (epicycloid_pts_cnt=0)                                     or
         (epicycloid_rad    =0)                                     or
         (epicycloid_angle  =0)                                     then
        with srf_var do
          begin
            LowerBmpToMainBmp;
            if world_axis_draw then
              WorldAxisDraw;
            CnvToCnv(srf_bmp_rct,F_MainForm.Canvas,srf_bmp.Canvas,SRCCOPY);
            Result:=True;
          end
      else
        Result:=False;
    end;
end; {$endregion}
function RoseRangeCheck      : boolean;                                                        {$region -fold}
begin
  with sln_var,global_prop do
    begin
      if (rose_pts_cnt   <3) or
         (rose_petals_cnt=0) or
         (rose_rad       =0) then
        with srf_var do
          begin
            LowerBmpToMainBmp;
            if world_axis_draw then
              WorldAxisDraw;
            CnvToCnv(srf_bmp_rct,F_MainForm.Canvas,srf_bmp.Canvas,SRCCOPY);
            Result:=True;
          end
      else
        Result:=False;
    end;
end; {$endregion}
procedure TF_MainForm.P_Drawing_PropMouseEnter                               (sender:TObject); {$region -fold}
begin
  P_Drawing_Prop.Color:=NAV_SEL_COL_1;
end; {$endregion}
procedure TF_MainForm.P_Drawing_PropMouseLeave                               (sender:TObject); {$region -fold}
begin
  P_Drawing_Prop.Color:=$00BAB5A3;
end; {$endregion}
procedure TF_MainForm.CB_Spline_TypeSelect                                   (sender:TObject); {$region -fold}
var
  b0,b1,b2: boolean;
begin
  if down_play_anim_ptr^ then
    Exit;
  with sln_var,global_prop do
    begin
      b0:=(CB_Spline_Type.ItemIndex=0);
      b1:=(CB_Spline_Type.ItemIndex=1);
      b2:=(CB_Spline_Type.ItemIndex=2);
      sln_type:=TSplineType(CB_Spline_Type.ItemIndex);
      if (not (b0 or b2)) and (cur_tlt_dwn_btn_ind<>-1) then
        L_Spline_Templates_Name.Caption:=sln_tlt_nam_arr1[cur_tlt_dwn_btn_ind];
      case cur_tlt_dwn_btn_ind of
        0: P_Cycloid   .Visible:=not (b0 or b2);
        1: P_Epicycloid.Visible:=not (b0 or b2);
        2: P_Rose      .Visible:=not (b0 or b2);
        3:;
        4:;
      end;
      P_Spline_Freehand        .Visible:=b0;
      P_Spline_Templates       .Visible:=b1 or b2;
      BB_Spline_Templates_Left .Visible:=b1;
      P_Spline_Template_List   .Visible:=b1;
      BB_Spline_Templates_Right.Visible:=b1;
      L_Spline_Points_Count    .Visible:=b2;
      SE_Spline_Points_Count   .Visible:=b2;
      if b2 then
        L_Spline_Templates_Name.Caption:='';
      if (b0 or b2) then
        srf_var.EventGroupsCalc(calc_arr,[30])
      else
        if (cur_tlt_dwn_btn_ind<>-1) then
          case cur_tlt_dwn_btn_ind of
            0:
              begin
                if CycloidRangeCheck then
                  Exit;
                SetLength    (fml_pts,cycloid_pts_cnt);
                FmlSplinePrev(        cycloid_pts_cnt);
              end;
            1:
              begin
                if EpicycloidRangeCheck then
                  Exit;
                SetLength    (fml_pts,epicycloid_pts_cnt);
                FmlSplinePrev(        epicycloid_pts_cnt);
              end;
            2:
              begin
                if RoseRangeCheck then
                  Exit;
                SetLength    (fml_pts,rose_pts_cnt);
                FmlSplinePrev(        rose_pts_cnt);
              end;
            3:;
            4:;
          end;
    end;
  VisibilityChange(b0);
end; {$endregion}
procedure TF_MainForm.P_Spline_FreehandMouseEnter                            (sender:TObject); {$region -fold}
begin
  P_Spline_Freehand         .Color:=HighLight(P_Spline_Freehand         .Color,0,0,0,0,0,16);
  P_Spline_Freehand_Settings.Color:=HighLight(P_Spline_Freehand_Settings.Color,0,0,0,0,0,16);
end; {$endregion}
procedure TF_MainForm.P_Spline_FreehandMouseLeave                            (sender:TObject); {$region -fold}
begin
  P_Spline_Freehand         .Color:=Darken(P_Spline_Freehand         .Color,0,0,0,0,0,16);
  P_Spline_Freehand_Settings.Color:=Darken(P_Spline_Freehand_Settings.Color,0,0,0,0,0,16);
end; {$endregion}
procedure TF_MainForm.CB_Spline_ModeSelect                                   (sender:TObject); {$region -fold}
begin
  L_Spline_Points_Freq  .visible:=((CB_Spline_Mode.ItemIndex=0) or (CB_Spline_Mode.ItemIndex=2));
  SE_Spline_Pts_Freq    .visible:=((CB_Spline_Mode.ItemIndex=0) or (CB_Spline_Mode.ItemIndex=2));
  L_Spline_Spray_Radius .visible:= (CB_Spline_Mode.ItemIndex=2);
  SE_Spline_Spray_Radius.visible:= (CB_Spline_Mode.ItemIndex=2);
  sln_var.global_prop.sln_mode  :=TSplineMode(CB_Spline_Mode.ItemIndex);
end; {$endregion}
procedure TF_MainForm.SE_Spline_Pts_FreqChange                               (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.sln_pts_frq:=SE_Spline_Pts_Freq.value;
end; {$endregion}
procedure TF_MainForm.SE_Spline_Pts_FreqKeyDown                              (sender:TObject; var key:word; shift:TShiftState); {$region -fold}
begin
  KeysDisable;
end; {$endregion}
procedure TF_MainForm.SE_Spline_Spray_RadiusChange                           (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.spray_rad:=SE_Spline_Spray_Radius.value;
end; {$endregion}
procedure TF_MainForm.BB_Spline_Templates_LeftClick                          (sender:TObject); {$region -fold}
begin
  ButtonMoveToPrevPos(P_Spline_Template_List,SB_Spline_Template_Superellipse,104,SB_Spline_Template_Superellipse.width,0,ptLeft);
end; {$endregion}
procedure TF_MainForm.BB_Spline_Templates_RightClick                         (sender:TObject); {$region -fold}
begin
  ButtonMoveToSuccPos(P_Spline_Template_List,SB_Spline_Template_Cycloid,004,SB_Spline_Template_Cycloid.width,0,ptLeft);
end; {$endregion}
procedure TF_MainForm.P_Spline_Template_ListMouseWheelUp                     (sender:TObject; shift:TShiftState; mousepos:TPoint; var Handled:boolean); {$region -fold}
begin
  //SB_Drawing.VertScrollBar.Position:=vert_sc_bar_pos+10;
  //SB_Drawing.VertScrollBar.Visible:=False;
  ButtonMoveToPrevPos(P_Spline_Template_List,SB_Spline_Template_Superellipse,104,SB_Spline_Template_Superellipse.width,0,ptLeft);
end; {$endregion}
procedure TF_MainForm.P_Spline_Template_ListMouseWheelDown                   (sender:TObject; shift:TShiftState; mousepos:TPoint; var Handled:boolean); {$region -fold}
begin
  //SB_Drawing.VertScrollBar.Position:=vert_sc_bar_pos-10;
  //SB_Drawing.VertScrollBar.Visible:=False;
  ButtonMoveToSuccPos(P_Spline_Template_List,SB_Spline_Template_Cycloid,004,SB_Spline_Template_Cycloid.width,0,ptLeft);
end; {$endregion}
procedure TF_MainForm.P_Spline_Template_ListPaint                            (sender:TObject); {$region -fold}
begin
  ButtonColorize(P_Spline_Template_List);
end; {$endregion}
procedure TF_MainForm.SplinesTemplatesNamesInit                            (sln_var_:TCurve ); {$region -fold}
begin
  with sln_var_ do
    begin
      sln_tlt_nam_arr1[0]:='Cycloid';
      sln_tlt_nam_arr1[1]:='Epicycloid';
      sln_tlt_nam_arr1[2]:='Rose';
      sln_tlt_nam_arr1[3]:='Spiral';
      sln_tlt_nam_arr1[4]:='Superellipse';
      sln_tlt_nam_arr2[0]:=@SB_Spline_Template_Cycloid     .Down;
      sln_tlt_nam_arr2[1]:=@SB_Spline_Template_Epicycloid  .Down;
      sln_tlt_nam_arr2[2]:=@SB_Spline_Template_Rose        .Down;
      sln_tlt_nam_arr2[3]:=@SB_Spline_Template_Spiral      .Down;
      sln_tlt_nam_arr2[4]:=@SB_Spline_Template_Superellipse.Down;
    end;
end; {$endregion}
procedure TF_MainForm.SB_Spline_TemplateClick                                (sender:TObject); {$region -fold}
type
  PPanel=^TPanel;
var
  panel_arr: array[0..2] of PPanel;
  i        : integer;

  procedure PanelsVisible; {$region -fold}
  var
    j: integer;
  begin
    panel_arr[0]:=@P_Cycloid   ;
    panel_arr[1]:=@P_Epicycloid;
    panel_arr[2]:=@P_Rose;
    for j:=0 to 2 do
      panel_arr[j]^.visible:=False;
  end; {$endregion}

begin
  with sln_var do
    begin
      cur_tlt_dwn_btn_ind:=-1;
      for i:=0 to P_Spline_Template_List.ControlCount-1 do
        if sln_tlt_nam_arr2[i]^ then
          begin
            cur_tlt_dwn_btn_ind:=i;
            Break;
          end;
      if (cur_tlt_dwn_btn_ind<>-1) then
        begin
          L_Spline_Templates_Name.Caption:=sln_tlt_nam_arr1[cur_tlt_dwn_btn_ind];
          case cur_tlt_dwn_btn_ind of
            0:
              begin
                PanelsVisible;
                global_prop.fml_type :=sfCycloid;
                panel_arr[0]^.visible:=True;
                if CycloidRangeCheck then
                  Exit;
                SetLength    (fml_pts,global_prop.cycloid_pts_cnt);
                FmlSplinePrev(        global_prop.cycloid_pts_cnt);
              end;
            1:
              begin
                PanelsVisible;
                if not CB_Epicycloid_Hypocycloid.Checked then
                  global_prop.fml_type:=sfEpicycloid
                else
                  global_prop.fml_type:=sfHypocycloid;
                panel_arr[1]^.visible :=True;
                if EpicycloidRangeCheck then
                  Exit;
                SetLength    (fml_pts,global_prop.epicycloid_pts_cnt);
                FmlSplinePrev(        global_prop.epicycloid_pts_cnt);
              end;
            2:
              begin
                PanelsVisible;
                global_prop.fml_type :=sfRose;
                panel_arr[2]^.visible:=True;
                if RoseRangeCheck then
                  Exit;
                SetLength    (fml_pts,global_prop.rose_pts_cnt);
                FmlSplinePrev(        global_prop.rose_pts_cnt);
              end;
            3:
              begin
                PanelsVisible;
                global_prop.fml_type:=sfSpiral;
              end;
            4:
              begin
                PanelsVisible;
                global_prop.fml_type:=sfSuperellipse;
              end;
          end;
        end
      else
        begin
          L_Spline_Templates_Name.Caption:='';
          sln_pts_cnt_add                :=0;
          PanelsVisible;
          srf_var.EventGroupsCalc(calc_arr,[30]);
        end;
    end;
end; {$endregion}
procedure TF_MainForm.P_Spline_TemplatesMouseEnter                           (sender:TObject); {$region -fold}
begin
  P_Spline_Templates_Properties.Color:=HighLight(P_Spline_Templates_Properties.Color,0,0,0,0,0,16);
  P_Spline_Templates           .Color:=HighLight(P_Spline_Templates           .Color,0,0,0,0,0,16);
end; {$endregion}
procedure TF_MainForm.P_Spline_TemplatesMouseLeave                           (sender:TObject); {$region -fold}
begin
  P_Spline_Templates_Properties.Color:=Darken(P_Spline_Templates_Properties.Color,0,0,0,0,0,16);
  P_Spline_Templates           .Color:=Darken(P_Spline_Templates           .Color,0,0,0,0,0,16);
end; {$endregion}
procedure TF_MainForm.P_Spline_Template_ListMouseEnter                       (sender:TObject); {$region -fold}
begin
  //vert_sc_bar_pos:=SB_Drawing.VertScrollBar.Position;
  //SB_Drawing.OnMouseWheelDown:=Nil;
  //SB_Drawing.OnMouseWheelUp:=Nil;
  //SB_Drawing.VertScrollBar.Position:=SB_Drawing.VertScrollBar.Position+10;
  //SB_Drawing.VertScrollBar.Visible:=False;
  P_Spline_Template_List.Color   :=HighLight(P_Spline_Template_List.Color,0,0,0,0,0,16);
end; {$endregion}
procedure TF_MainForm.P_Spline_Template_ListMouseLeave                       (sender:TObject); {$region -fold}
begin
  //SB_Drawing.VertScrollBar.Visible:=True;
  P_Spline_Template_List.Color:=Darken(P_Spline_Template_List.Color,0,0,0,0,0,16);
end; {$endregion}
procedure TF_MainForm.BB_GenerateClick                                       (sender:TObject); {$region -fold}
begin
  with srf_var,sln_var,global_prop do
    begin
      if (not show_spline) then
        Exit;
      case CB_Spline_Type.ItemIndex of
        1:
          begin
            if (cur_tlt_dwn_btn_ind=-1) then
              Exit;
            case cur_tlt_dwn_btn_ind of
              0:
                begin
                  if CycloidRangeCheck then
                    Exit;
                  sln_pts_cnt_add:=cycloid_pts_cnt;
                end;
              1:
                begin
                  if EpicycloidRangeCheck then
                    Exit;
                  sln_pts_cnt_add:=epicycloid_pts_cnt;
                end;
              2:
                begin
                  if RoseRangeCheck then
                    Exit;
                  sln_pts_cnt_add:=rose_pts_cnt;
                end;
              3:;
              4:;
            end;
            FmlSplineObj[cur_tlt_dwn_btn_ind](world_axis.x,world_axis.y);
            Inc(sln_pts_cnt,sln_pts_cnt_add);
            sln_pts_add:=fml_pts;
            EventGroupsCalc(calc_arr,[12,16,30,33]);
          end;
        2:
          begin
            if (pts_cnt_val=0) then
              Exit;
            RndSplineObj(world_axis,512{256},512{256});
            EventGroupsCalc(calc_arr,[12,16,30,33]);
          end;
      end;
    end;
end; {$endregion}
procedure TF_MainForm.SE_Cycloid_Points_CountChange                          (sender:TObject); {$region -fold}
begin
  with sln_var,global_prop do
    begin
      cycloid_pts_cnt:=SE_Cycloid_Points_Count.value;
      if CycloidRangeCheck then
        Exit;
      SetLength(fml_pts,cycloid_pts_cnt);
      FmlSplinePrev(cycloid_pts_cnt);
    end;
end; {$endregion}
procedure TF_MainForm.SE_Cycloid_Loops_CountChange                           (sender:TObject); {$region -fold}
begin
  with sln_var,global_prop do
    begin
      cycloid_loop_cnt:=SE_Cycloid_Loops_Count.value;
      if CycloidRangeCheck then
        Exit;
      FmlSplinePrev(cycloid_pts_cnt);
    end;
end; {$endregion}
procedure TF_MainForm.SE_Cycloid_RadiusChange                                (sender:TObject); {$region -fold}
begin
  with sln_var,global_prop do
    begin
      cycloid_loop_rad:=SE_Cycloid_Radius.value;
      if CycloidRangeCheck then
        Exit;
      FmlSplinePrev(cycloid_pts_cnt);
    end;
end; {$endregion}
procedure TF_MainForm.FSE_Cycloid_CurvatureChange                            (sender:TObject); {$region -fold}
begin
  with sln_var,global_prop do
    begin
      cycloid_curvature:=FSE_Cycloid_Curvature.value;
      FmlSplinePrev(cycloid_pts_cnt);
    end;
end; {$endregion}
procedure TF_MainForm.CB_Cycloid_Direction_XSelect                           (sender:TObject); {$region -fold}
begin
  with sln_var,global_prop do
    begin
      cycloid_dir_x:=TMovingDirection(CB_Cycloid_Direction_X.ItemIndex);
      FmlSplinePrev(cycloid_pts_cnt);
    end;
end; {$endregion}
procedure TF_MainForm.CB_Cycloid_Direction_YSelect                           (sender:TObject); {$region -fold}
begin
  with sln_var,global_prop do
    begin
      cycloid_dir_y:=TMovingDirection(CB_Cycloid_Direction_Y.ItemIndex+2);
      FmlSplinePrev(cycloid_pts_cnt);
    end;
end; {$endregion}
procedure TF_MainForm.SE_Epicycloid_Points_CountChange                       (sender:TObject); {$region -fold}
begin
  with sln_var,global_prop do
    begin
      epicycloid_pts_cnt:=SE_Epicycloid_Points_Count.value;
      if EpicycloidRangeCheck then
        Exit;
      SetLength    (fml_pts,epicycloid_pts_cnt);
      FmlSplinePrev(        epicycloid_pts_cnt);
    end;
end; {$endregion}
procedure TF_MainForm.SE_Epicycloid_Petals_CountChange                       (sender:TObject); {$region -fold}
begin
  with sln_var,global_prop do
    begin
      epicycloid_petals_cnt:=SE_Epicycloid_Petals_Count.value;
      if EpicycloidRangeCheck then
        Exit;
      FmlSplinePrev(epicycloid_pts_cnt);
    end;
end; {$endregion}
procedure TF_MainForm.SE_Epicycloid_RadiusChange                             (sender:TObject); {$region -fold}
begin
  with sln_var,global_prop do
    begin
      epicycloid_rad:=SE_Epicycloid_Radius.value;
      if EpicycloidRangeCheck then
        Exit;
      FmlSplinePrev(epicycloid_pts_cnt);
    end;
end; {$endregion}
procedure TF_MainForm.SE_Epicycloid_RotationChange                           (sender:TObject); {$region -fold}
begin
  with sln_var,global_prop do
    begin
      epicycloid_rot:=SE_Epicycloid_Rotation.value;
      FmlSplinePrev(epicycloid_pts_cnt);
    end;
end; {$endregion}
procedure TF_MainForm.SE_Epicycloid_AngleChange                              (sender:TObject); {$region -fold}
begin
  with sln_var,global_prop do
    begin
      epicycloid_angle:=SE_Epicycloid_Angle.value;
      if EpicycloidRangeCheck then
        Exit;
      FmlSplinePrev(epicycloid_pts_cnt);
    end;
end; {$endregion}
procedure TF_MainForm.CB_Epicycloid_HypocycloidChange                        (sender:TObject); {$region -fold}
begin
  with sln_var,global_prop do
    begin
      if CB_Epicycloid_Hypocycloid.Checked then
        fml_type:=sfHypocycloid
      else
        fml_type:=sfEpicycloid;
      if EpicycloidRangeCheck then
        Exit;
      FmlSplinePrev(epicycloid_pts_cnt);
    end;
end; {$endregion}
procedure TF_MainForm.SE_Rose_Points_CountChange                             (sender:TObject); {$region -fold}
begin
  with sln_var,global_prop do
    begin
      rose_pts_cnt:=SE_Rose_Points_Count.value;
      if RoseRangeCheck then
        Exit;
      SetLength    (fml_pts,rose_pts_cnt);
      FmlSplinePrev(        rose_pts_cnt);
    end;
end; {$endregion}
procedure TF_MainForm.FSE_Rose_Petals_CountChange                            (sender:TObject); {$region -fold}
begin
  with sln_var,global_prop do
    begin
      rose_petals_cnt:=FSE_Rose_Petals_Count.value;
      if RoseRangeCheck then
        Exit;
      FmlSplinePrev(rose_pts_cnt);
    end;
end; {$endregion}
procedure TF_MainForm.SE_Rose_RadiusChange                                   (sender:TObject); {$region -fold}
begin
  with sln_var,global_prop do
    begin
      rose_rad:=SE_Rose_Radius.value;
      if RoseRangeCheck then
        Exit;
      FmlSplinePrev(rose_pts_cnt);
    end;
end; {$endregion}
procedure TF_MainForm.SE_Rose_RotationChange                                 (sender:TObject); {$region -fold}
begin
  with sln_var,global_prop do
    begin
      rose_rot:=SE_Rose_Rotation.value;
      FmlSplinePrev(rose_pts_cnt);
    end;
end; {$endregion}
procedure TF_MainForm.SE_Rose_AngleChange                                    (sender:TObject); {$region -fold}
begin
  with sln_var,global_prop do
    begin
      rose_angle:=SE_Rose_Angle.value;
      FmlSplinePrev(rose_pts_cnt);
    end;
end; {$endregion}
procedure TF_MainForm.SE_Spline_Points_CountChange                           (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.pts_cnt_val:=SE_Spline_Points_Count.Value;
end; {$endregion}
{Optimization}
procedure TF_MainForm.P_Optimization_PropMouseEnter                          (sender:TObject); {$region -fold}
begin
  P_Optimization_Prop.Color:=NAV_SEL_COL_1;
end; {$endregion}
procedure TF_MainForm.P_Optimization_PropMouseLeave                          (sender:TObject); {$region -fold}
begin
  P_Optimization_Prop.Color:=$00BAB5A3;
end; {$endregion}
procedure TF_MainForm.CB_Spline_Edges_LODChange                              (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.eds_lod            :=not sln_var.global_prop.eds_lod;
  FSE_Spline_Simplification_Angle.Enabled:=CB_Spline_Edges_LOD.Checked;
  L_Spline_Simplification_Angle  .Enabled:=CB_Spline_Edges_LOD.Checked;
end; {$endregion}
procedure TF_MainForm.FSE_Spline_Simplification_AngleChange                  (sender:TObject); {$region -fold}
begin

end; {$endregion}
procedure TF_MainForm.CB_Spline_Hidden_Line_EliminationChange                (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.hid_ln_elim:=not sln_var.global_prop.hid_ln_elim;
end; {$endregion}
procedure TF_MainForm.CB_Spline_Lazy_RepaintChange                           (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.lazy_repaint:=not sln_var.global_prop.lazy_repaint;
end; {$endregion}
procedure TF_MainForm.CB_Spline_Byte_ModeChange                              (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.byte_mode:=not sln_var.global_prop.byte_mode;
end; {$endregion}
procedure TF_MainForm.CB_Spline_On_Out_Of_WindowChange                       (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.free_mem_on_out_of_wnd:=not sln_var.global_prop.free_mem_on_out_of_wnd;
end; {$endregion}
procedure TF_MainForm.CB_Spline_On_Scale_DownChange                          (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.free_mem_on_scale_down:=not sln_var.global_prop.free_mem_on_scale_down;
end; {$endregion}
procedure TF_MainForm.RB_Spline_AdaptiveChange                               (sender:TObject); {$region -fold}
begin
  with sln_var.global_prop do
    begin
      remove_brunching_adaptive:=RB_Spline_Adaptive.Checked;
      remove_brunching_constant:=RB_Spline_Constant  .Checked;
      remove_brunching_none    :=RB_Spline_None    .Checked;
    end;
end; {$endregion}
{Dynamics}
procedure TF_MainForm.CB_Dynamics_StyleSelect                                (sender:TObject); {$region -fold}
begin
  sln_var.global_prop.dyn_stl:=TDynamicsStyle(CB_Dynamics_Style.ItemIndex);
  //F_MainForm.Memo1.Lines.Text:=GetEnumName(TypeInfo(TDynamicsStyle),Ord(TDynamicsStyle(F_MainForm.CB_Dynamics_Style.ItemIndex)));
end; {$endregion}
procedure TF_MainForm.P_Dynamics_PropMouseEnter                              (sender:TObject); {$region -fold}
begin
  P_Dynamics_Prop.Color:=NAV_SEL_COL_1;
end; {$endregion}
procedure TF_MainForm.P_Dynamics_PropMouseLeave                              (sender:TObject); {$region -fold}
begin
  P_Dynamics_Prop.Color:=$00BAB5A3;
end; {$endregion}
{Save/Load}
procedure TF_MainForm.P_Save_Load_PropMouseEnter                             (sender:TObject); {$region -fold}
begin
  P_Save_Load_Prop.Color:=NAV_SEL_COL_1;
end; {$endregion}
procedure TF_MainForm.P_Save_Load_PropMouseLeave                             (sender:TObject); {$region -fold}
begin
  P_Save_Load_Prop.Color:=$00BAB5A3;
end; {$endregion}
{$endregion}

// (Select Points) Выделение точек:
{LI} {$region -fold}
constructor TSelPts.Create(constref w,h:TColor; constref bkgnd_ptr:PInteger; constref bkgnd_width,bkgnd_height:TColor; var rct_out:TPtRect);          {$ifdef Linux}[local];{$endif} {$region -fold}
begin

  outer_subgraph_img:=TFastLine.Create;
  with outer_subgraph_img,local_prop do
    begin
      //local_prop :=curve_default_prop;
      eds_col    :=clLime;
      eds_col_inv:=SetColorInv(eds_col);
      eds_aa     :=True;
      SetColorInfo(eds_col,color_info);
      with args do
        begin
          alpha:=064;
          pow  :=032;
          d    :=032;
        end;
    end;

  inner_subgraph_img:=TFastLine.Create;
  with inner_subgraph_img,local_prop do
    begin
      //local_prop :=curve_default_prop;
      eds_col    :=clBlue;
      eds_col_inv:=SetColorInv(eds_col);
      eds_aa     :=True;
      SetColorInfo(eds_col,color_info);
      with args do
        begin
          alpha:=064;
          pow  :=032;
          d    :=032;
        end;
    end;

  sel_pts_big_img:=TFastLine.Create;
  with sel_pts_big_img,local_prop do
    begin
      rct_out    :=PtRct(0,0,bkgnd_width,bkgnd_height);
      rct_out_ptr:=@rct_out;
      local_prop :=curve_default_prop;
      eds_col    :=clGreen;
      eds_col_inv:=SetColorInv(eds_col);
      eds_aa     :=True;
      pts_col    :=clLime;
      pts_col_inv:=SetColorInv(pts_col);
      SetColorInfo(eds_col,color_info);
      with args do
        begin
          alpha:=064;
          pow  :=032;
          d    :=032;
        end;
      SplineInit(w,h,False,True,False,False);
      SetBkgnd  (bkgnd_ptr,bkgnd_width,bkgnd_height);
    end;

  sel_bmp                   :=Graphics.TBitmap.Create;
  sel_bmp.Width             :=w;
  sel_bmp.Height            :=h;
  bucket_rct.Width          :=8;
  bucket_rct.Height         :=8;
  draw_out_subgraph         :=True;
  draw_inn_subgraph         :=True;
  draw_selected_pts         :=True;
  is_not_abst_obj_kind_after:=True;
  sel_mode                  :=smCircle;

end; {$endregion}
destructor  TSelPts.Destroy;                                                                                                                          {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  inherited Destroy;
end; {$endregion}
procedure BucketSizeChange(chng_val:integer);                                                                                                 inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i,bucket_mul,m1,m2: integer;
begin
  with srf_var,sel_var do
    begin
      bucket_mul        :=4;
      bucket_rct.Width :=Trunc(sqrt(sel_pts_rct.width*sel_pts_rct.height*chng_val)/(10*bucket_mul));
      bucket_rct.Height:=Trunc(sqrt(sel_pts_rct.width*sel_pts_rct.height*chng_val)/(10*bucket_mul));
      ncs_adv_clip_rect :=NCSRectCalc(sel_pts_rct,
                                      bucket_rct.width,
                                      bucket_rct.height);
      LowerBmpToMainBmp;
      if show_selected_pts_b_rect then
        SelectedPtsRectDraw(srf_bmp.Canvas,sel_pts_rct,clPurple,clNavy);
      {PtsRectDraw1(srf_bmp.Canvas,
                   ncs_adv_clip_rect,clRed);}
      with srf_bmp.Canvas do
        begin
          Pen.Color:=bucket_rct_color;
          m1:=Trunc(ncs_adv_clip_rect.width /bucket_rct.width )-2;
          m2:=Trunc(ncs_adv_clip_rect.height/bucket_rct.height)-2;
          for i:=0 to m1 do
            Line(ncs_adv_clip_rect.left+bucket_rct.width*(i+1),
                 ncs_adv_clip_rect.top,
                 ncs_adv_clip_rect.left+bucket_rct.width*(i+1),
                 ncs_adv_clip_rect.top +ncs_adv_clip_rect.height);
          for i:=0 to m2 do
            Line(ncs_adv_clip_rect.left,
                 ncs_adv_clip_rect.top +bucket_rct.height*(i+1),
                 ncs_adv_clip_rect.left+ncs_adv_clip_rect.width,
                 ncs_adv_clip_rect.top +bucket_rct.height*(i+1));
        end;
      InvalidateInnerWindow;
      {$ifdef Windows}
      Sleep(2);
      {$else}
      USleep(2000000);
      {$endif}
    end;
end; {$endregion}
procedure IsObjColorAMaskColor;                                                                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with sel_var do
    begin
      if (outer_subgraph_img.local_prop.eds_col =clBlack) then
        begin
          outer_subgraph_img.local_prop.eds_col:=$01;
          F_MainForm.CD_Select_Color.Color     :=$01;
        end;
      if (inner_subgraph_img.local_prop.eds_col =clBlack) then
        begin
          inner_subgraph_img.local_prop.eds_col:=$01;
          F_MainForm.CD_Select_Color.Color     :=$01;
        end;
      if (sel_pts_big_img.local_prop.eds_col   =clBlack) then
        begin
          sel_pts_big_img.local_prop.eds_col  :=$01;
          F_MainForm.CD_Select_Color.Color    :=$01;
        end;
    end;
end; {$endregion}
procedure FillSelectedBmpAndSelectedPtsBRectDraw;                                                                                             inline; {$ifdef linux}[local];{$endif} {$region -fold}
begin
  if exp0 then
    if show_spline then
      with srf_var,sln_var,sel_var do
        begin
          LowerBmpToMainBmp;
          {Fill Selected Bmp}
          if draw_out_subgraph then
            OuterSubgraphToBmp(Trunc(pvt_var.pvt.X),
                               Trunc(pvt_var.pvt.Y),
                               pvt_var.pvt,
                               sln_pts,
                               srf_bmp_ptr,
                               inn_wnd_rct);
          if draw_inn_subgraph and (not IsRct1OutOfRct2(sel_var.sel_pts_rct,inn_wnd_rct)) then
            InnerSubgraphToBmp(Trunc(pvt_var.pvt.X),
                               Trunc(pvt_var.pvt.Y),
                               pvt_var.pvt,
                               sln_pts,
                               srf_bmp_ptr,
                               ClippedRct(inn_wnd_rct,sel_pts_rct));
          if draw_selected_pts then
            SelectdPointsToBmp(Trunc(pvt_var.pvt.X),
                               Trunc(pvt_var.pvt.Y),
                               pvt_var.pvt,
                               sln_pts,
                               srf_bmp_ptr,
                               inn_wnd_rct);
          {Draw Selected Points Bounding Rectangle}
          if show_selected_pts_b_rect then
            SelectedPtsRectDraw(srf_bmp.Canvas,sel_pts_rct,clPurple,clNavy);
          InvalidateInnerWindow;
        end;
end; {$endregion}
constructor TCircSel.Create;                                                                                                                          {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  crc_sel_col :=clGreen;
  crc_rad     :=10;
  crc_rad_sqr :=crc_rad*crc_rad;
  draw_crc_sel:=True;
end; {$endregion}
destructor  TCircSel.Destroy;                                                                                                                         {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  inherited Destroy;
end; {$endregion}
procedure TCircSel.CircleSelection        (x,y:integer; constref m_c_var:TSurf; constref s_c_var:TSelPts; constref pts:TPtPosFArr; constref pts_cnt:TColor; constref sel_draw:boolean=True); {$ifdef Linux}[local];{$endif} {$region -fold}
var
  is_point_selected_ptr: PByteBool;
  sel_pts_inds_ptr     : PInteger;
  pts_ptr              : PPtPosF;
  i,m1,m2,m3,m4        : integer;
begin

  {Set Bounding Rectangle---------------} {$region -fold}
  with m_c_var.inn_wnd_rct do
    begin
      m1:=left  +inn_wnd_mrg;
      m2:=top   +inn_wnd_mrg;
      m3:=right -inn_wnd_mrg;
      m4:=bottom-inn_wnd_mrg;
    end; {$endregion}

  {Drawing Of Selected Points Rectangles} {$region -fold}
  with m_c_var,s_c_var do
    begin
      if sel_draw then
        begin
          sel_pts_big_img.bmp_dst_ptr :=srf_bmp_ptr;
          sel_pts_big_img.ln_arr_width:=srf_bmp_rct.Width;
          if not ((X-crc_rad>m1)  and
                  (X+crc_rad<m3)  and
                  (Y-crc_rad>m2)  and
                  (Y+crc_rad<m4)) then
            begin
              pts_ptr              :=@pts              [0];
              is_point_selected_ptr:=@is_point_selected[0];
              sel_pts_inds_ptr     :=@sel_pts_inds     [0];
              for i:=0 to pts_cnt-1 do
                begin
                  if (pts_ptr^.x+world_axis_shift.x>m1)                        and
                     (pts_ptr^.x+world_axis_shift.x<m3)                        and
                     (pts_ptr^.y+world_axis_shift.y>m2)                        and
                     (pts_ptr^.y+world_axis_shift.y<m4)                        and
                     (sqr(Trunc(pts_ptr^.x)+world_axis_shift.x-x)+
                      sqr(Trunc(pts_ptr^.y)+world_axis_shift.y-y)<crc_rad_sqr) and
                     (not (is_point_selected_ptr+i)^)                          then
                    begin
                      (is_point_selected_ptr+i)^     :=True;
                      (sel_pts_inds_ptr+sel_pts_cnt)^:=i;
                      Rectangle
                      (
                        Trunc(pts_ptr^.x)+world_axis_shift.x,
                        Trunc(pts_ptr^.y)+world_axis_shift.y,
                        low_bmp_ptr,
                        low_bmp.width,
                        low_bmp.height,
                        inn_wnd_rct,
                        sel_pts_big_img.local_prop
                      );
                      Inc(sel_pts_cnt);
                    end;
                  Inc(pts_ptr);
                end;
            end
          else
            begin
              pts_ptr              :=@pts              [0];
              is_point_selected_ptr:=@is_point_selected[0];
              sel_pts_inds_ptr     :=@sel_pts_inds     [0];
              for i:=0 to pts_cnt-1 do
                begin
                  if (sqr(Trunc(pts_ptr^.x)+world_axis_shift.x-x)+
                      sqr(Trunc(pts_ptr^.y)+world_axis_shift.y-y)<crc_rad_sqr) and
                     (not (is_point_selected_ptr+i)^)                          then
                      begin
                        (is_point_selected_ptr+i)^     :=True;
                        (sel_pts_inds_ptr+sel_pts_cnt)^:=i;
                        Rectangle
                        (
                          Trunc(pts_ptr^.x)+world_axis_shift.x,
                          Trunc(pts_ptr^.y)+world_axis_shift.y,
                          low_bmp_ptr,
                          low_bmp.width,
                          low_bmp.height,
                          inn_wnd_rct,
                          sel_pts_big_img.local_prop
                        );
                        Inc(sel_pts_cnt);
                      end;
                  Inc(pts_ptr);
                end;
            end;
        end
      else
        begin
          sel_pts_big_img.bmp_dst_ptr :=srf_bmp_ptr;
          sel_pts_big_img.ln_arr_width:=srf_bmp_rct.Width;
          if not ((X-crc_rad>m1)  and
                  (X+crc_rad<m3)  and
                  (Y-crc_rad>m2)  and
                  (Y+crc_rad<m4)) then
            begin
              pts_ptr              :=@pts              [0];
              is_point_selected_ptr:=@is_point_selected[0];
              sel_pts_inds_ptr     :=@sel_pts_inds     [0];
              for i:=0 to pts_cnt-1 do
                begin
                  if (pts_ptr^.x+world_axis_shift.x>m1)                        and
                     (pts_ptr^.x+world_axis_shift.x<m3)                        and
                     (pts_ptr^.y+world_axis_shift.y>m2)                        and
                     (pts_ptr^.y+world_axis_shift.y<m4)                        and
                     (sqr(Trunc(pts_ptr^.x)+world_axis_shift.x-x)+
                      sqr(Trunc(pts_ptr^.y)+world_axis_shift.y-y)<crc_rad_sqr) and
                     (not (is_point_selected_ptr+i)^)                          then
                    begin
                      (is_point_selected_ptr+i)^     :=True;
                      (sel_pts_inds_ptr+sel_pts_cnt)^:=i;
                      Inc(sel_pts_cnt);
                    end;
                  Inc(pts_ptr);
                end;
            end
          else
            begin
              pts_ptr              :=@pts              [0];
              is_point_selected_ptr:=@is_point_selected[0];
              sel_pts_inds_ptr     :=@sel_pts_inds     [0];
              for i:=0 to pts_cnt-1 do
                begin
                  if (sqr(Trunc(pts_ptr^.x)+world_axis_shift.x-x)+
                      sqr(Trunc(pts_ptr^.y)+world_axis_shift.y-y)<crc_rad_sqr) and
                     (not (is_point_selected_ptr+i)^)                          then
                    begin
                      (is_point_selected_ptr+i)^     :=True;
                      (sel_pts_inds_ptr+sel_pts_cnt)^:=i;
                      Inc(sel_pts_cnt);
                    end;
                  Inc(pts_ptr);
                end;
            end;
        end
    end; {$endregion}

end; {$endregion}
procedure TCircSel.CircleSelectionModeDraw(x,y:integer; constref m_c_var:TSurf);                                                              inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with srf_var do
    if IsPtInRct(x,y,PtRct(inn_wnd_rct.left  +crc_rad,
                           inn_wnd_rct.top   +crc_rad,
                           inn_wnd_rct.right -crc_rad,
                           inn_wnd_rct.bottom-crc_rad)) then
      Circle (x,y,crc_rad,srf_bmp_ptr,            srf_bmp.width,crc_sel_col)
    else
      CircleC(x,y,crc_rad,srf_bmp_ptr,inn_wnd_rct,srf_bmp.width,crc_sel_col);
end; {$endregion}
procedure TCircSel.ResizeCircleSelectionModeDraw;                                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sel_pos: TPtPos;
begin
  GetCursorPos(TPoint(sel_pos));
  sel_pos           :=TPtPos(F_MainForm.ScreenToClient(TPoint(sel_pos)));
  crc_sel_rct.left  :=sel_pos.x-crc_rad;
  crc_sel_rct.top   :=sel_pos.y-crc_rad;
  crc_sel_rct.width :=crc_rad<<1;
  crc_sel_rct.height:=crc_rad<<1;
end; {$endregion}
constructor TBrushSel.Create;                                                                                                                         {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  draw_brs_sel:=False;
end; {$endregion}
destructor  TBrushSel.Destroy;                                                                                                                        {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  inherited Destroy;
end; {$endregion}
constructor TRectSel.Create;                                                                                                                          {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  rct_width:=10;
end; {$endregion}
destructor  TRectSel.Destroy;                                                                                                                         {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  inherited Destroy;
end; {$endregion}
procedure TSelPts.ChangeSelectionMode(item_ind:TColor);                                                                                       inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  crc_sel_var.draw_crc_sel:=False;
  brs_sel_var.draw_brs_sel:=False;
  case item_ind of
    0:
      begin
        crc_sel_var.draw_crc_sel:=True;
        sel_mode                :=smCircle;
      end;
    1:
      begin
        crc_sel_var.draw_crc_sel:=True;
        sel_mode                :=smBrush;
      end;
    2:
      begin
        sel_mode:=smRectangle;

      end;
    3:
      begin
        sel_mode:=smRegion;

      end;
  end;
  case sel_mode of
    smCircle,smBrush:
      with crc_sel_var do
        begin
          ResizeCircleSelectionModeDraw;
          AddCircleSelection;
          CrtCircleSelection;
          FilSelPtsObj(crc_sel_rct.left,crc_sel_rct.top); //CircleSelectionModeDraw(x,y,srf_var);
        end;
  end;
  //InvalidateInnerWindow;
end; {$endregion}
procedure TSelPts.AddCircleSelection;                                                                                                         inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  with sel_pts_big_img,local_prop,crc_sel_var do
    begin
      Circle(crc_rad+1,crc_rad+1,crc_rad,ln_arr1_ptr,ln_arr_width,1);
      if (sel_mode=smBrush) then
        begin
          Circle(crc_rad+0001,crc_rad+0001,crc_rad-0006,ln_arr1_ptr,ln_arr_width,1);
          LineH (000000000001,crc_rad+0001,000000000008,ln_arr1_ptr,ln_arr_width,1);
          LineH (crc_rad<<1-6,crc_rad+0001,crc_rad<<1+1,ln_arr1_ptr,ln_arr_width,1);
          LineV (crc_rad+0001,000000000001,000000000008,ln_arr1_ptr,ln_arr_width,1);
          LineV (crc_rad+0001,crc_rad<<1-6,crc_rad<<1+1,ln_arr1_ptr,ln_arr_width,1);
          {for i:=0 to 100 do
            (ln_arr1_ptr+Random(crc_rad<<1)+Random(crc_rad<<1)*ln_arr_width)^:=1;}
        end;
    end;
end; {$endregion}
procedure TSelPts.PrimitiveComp(constref pmt_img_ptr:PFastLine; pmt_bld_stl:TDrawingStyle);                                                   inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  bmp_alpha_ptr2_: PByte;
begin
  with pmt_img_ptr^,local_prop,fst_img do
    begin
      with rct_vis do
        SetRctPos
        (
          left,
          top
        );
      SetValInfo
      (
        ln_arr1_ptr,
        ln_arr1_ptr,
        ln_arr1_ptr,
        ln_arr_width,
        ln_arr_height
      );
      SetBkgnd
      (
        bmp_dst_ptr,
        bmp_dst_width,
        bmp_dst_height
      );
      bmp_src_rct_clp          :=PtRct(rct_vis);
      img_kind                 :={1}5;
      pix_drw_type             :=1; //must be in range of [0..002]
      fx_cnt                   :=1; //must be in range of [0..255]
      fx_arr[0].rep_cnt        :=1; //must be in range of [0..255]
      fx_arr[0].nt_pix_srf_type:=1; //must be in range of [0..001]
      fx_arr[0].nt_pix_cfx_type:=GetEnumVal(pmt_bld_stl);
      fx_arr[0].pt_pix_srf_type:=1; //must be in range of [0..001]
      fx_arr[0].pt_pix_cfx_type:=fx_arr[0].nt_pix_cfx_type;
    //nt_pix_srf_type          :=0;
    //pt_pix_srf_type          :=0;
      col_trans_arr[2]         :=064;
      col_trans_arr[4]         :=100;
      col_trans_arr[5]         :=100;
      CmpProc[11];

      {Edges Anti-Aliasing---} {$region -fold}
      if eds_aa then
        begin

          {Calc. Anti-Aliased Border----------} {$region -fold}
          {ArrClear    (aa_arr1,
                       PtRct(rct_vis),
                       ln_arr_width);}
          {Fast_Primitives.}
          //ArrClear(srf_var.test_bmp_ptr,srf_var.inn_wnd_rct,srf_var.test_bmp.width,1,1,1,1);
          BorderCalc1 (ln_arr1,
                       aa_arr1,
                       ln_arr_width,
                       ln_arr_width,
                       PtRct(rct_vis){,
                       aa_nz_arr_items_count});
          //ArrFill (aa_arr1,srf_var.test_bmp_ptr,srf_var.test_bmp.width,srf_var.test_bmp.height,srf_var.inn_wnd_rct,False);
          {bmp_alpha_ptr2_:=bmp_alpha_ptr2;
          bmp_alpha_ptr2:=@aa_arr1[0];
          CrtPTCountArrB;
          CrtPTShiftArrB;
          CrtPTCntIndArr;
          bmp_alpha_ptr2:=bmp_alpha_ptr2_;}
          BorderCalc20(ln_arr1,
                       aa_arr1,
                       aa_arr2,
                       ln_arr_width,
                       ln_arr_width,
                       PtRct(rct_vis),
                       aa_line_cnt);
          {ArrFill (aa_arr1,srf_var.test_bmp_ptr,srf_var.test_bmp.width,srf_var.test_bmp.height,srf_var.inn_wnd_rct,False);
          F_MainForm.Memo1.Lines.Text:=IntToStr(2 or 3){IntToStr(nt_pix_cnt)+';'+IntToStr(pt_pix_cnt)+';'+IntToStr(pt_pix_intr_cnt_arr[1])};} {$endregion}

          {Clear Buffer-----------------------} {$region -fold}
          FilNTValueArrA(ln_arr1,ln_arr_width); {$endregion}

          {Fill Anti-Aliased Border-----------} {$region -fold}
          BorderFill(aa_arr2,
                     0,
                     0,
                     ln_arr1_ptr,
                     ln_arr_width,
                     aa_line_cnt,
                     eds_col,
                     args); {$endregion}

          {Compress Anti-Aliased Alpha Channel} {$region -fold}
          CrtPTCountBmpO;
          CrtPTShiftBmpO;
          CrtPTCntIndArr;
          StrPTAlphaArrO; {$endregion}

          {Clear Buffer-----------------------} {$region -fold}
          FilPTValueArrA(ln_arr1,ln_arr_width);
          FilPTValueArrB(aa_arr1,ln_arr_width); {$endregion}

        end; {$endregion}

      SetRctPos(bmp_src_rct_clp);
      SetSdrType;
    end;
end; {$endregion}
procedure TSelPts.CrtCircleSelection;                                                                                                                 {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with sel_pts_big_img,local_prop do
    begin

      {Set Bounding Rectangle} {$region -fold}
      with rct_vis do
        begin
          left  :=0;
          top   :=0;
          right :=crc_sel_var.crc_rad<<1+3;
          bottom:=right;
          width :=right-left;
          height:=bottom-top;
        end; {$endregion}

      {Create Sprite---------} {$region -fold}
      if (fst_img=Nil) then
          fst_img:=TFastImage.Create
          (
            bmp_dst_ptr,
            bmp_dst_width,
            bmp_dst_height,
            rct_out_ptr^,
            PtRct(rct_vis),
            0
          ); {$endregion}

      {Compress Sprite-------} {$region -fold}
      // clear buffers:
      fst_img.ClrArr({%0000011111111111}%0000000011111111);

      // set color of spline edges:
      fst_img.SetPPInfo(eds_col);

      // compress edges sprite:
      PrimitiveComp(@sel_pts_big_img,eds_bld_stl); {$endregion}

    end;
end; {$endregion}
procedure TSelPts.FilSelPtsObj(constref x,y:integer);                                                                                         inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with sel_pts_big_img,fst_img do
    begin
      SetRctPos(x,y);
      SdrProc[3];
    end;
end; {$endregion}
procedure TSelPts.MinimizeCircleSelection;                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with crc_sel_var do
    begin
      crc_rad     :=10;
      crc_rad_sqr :=crc_rad*crc_rad;
      ResizeCircleSelectionModeDraw;
      AddCircleSelection;
      CrtCircleSelection;
      FilSelPtsObj(crc_sel_rct.left,crc_sel_rct.top); //CircleSelectionModeDraw(x,y,srf_var);
    end;
end; {$endregion}
procedure TSelPts.SelectAllPts(const pts_cnt,eds_cnt:TColor);                                                                                 inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
end; {$endregion}
procedure TSelPts.SelectedPtsRectDraw(cnv_dst:TCanvas; b_rct:TRect; color1,color2:TColor);                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  {PtsRectDraw2(cnv_dst,b_rct,color1,color2);}
end; {$endregion}
procedure TSelPts.SubgraphCalc(var has_sel_pts:T1Byte1Arr; constref pts:TPtPosFArr; constref fst_lst_sln_obj_pts:TEnum0Arr; constref obj_ind:TColorArr; constref sln_obj_cnt:TColor; constref sln_pts_cnt:TColor); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  outer_subgraph1_ptr        : PEdge;
  outer_subgraph2_ptr        : PEdge;
  outer_subgraph3_ptr        : PEdge;
  inner_subgraph__ptr        : PEdge;
  sl_pt_subgraph__ptr        : PSlPt;
  obj_ind_ptr                : PInteger;
  sel_pts_inds_ptr           : PInteger;
  out_or_inn_subgraph_pts_ptr: PByte;
  fst_lst_sln_obj_pts_ptr    : PByte;
  is_point_selected_ptr      : PByteBool;
  has_sel_pts_ptr            : PByte;
  f_arr                      : TColorArr;
  i,c                        : integer;
  b                          : integer;
begin

  {Misc. Precalc.-----------------------} {$region -fold}
  c:=Min(2*sel_pts_cnt,sln_pts_cnt); {$endregion}

  {Clear Arrays-------------------------} {$region -fold}
  SetLength(outer_subgraph1,0);
  SetLength(outer_subgraph2,0);
  SetLength(outer_subgraph3,0);
  SetLength(inner_subgraph_,0);
  SetLength(sl_pt_subgraph_,0);
  FillByte((@has_sel_pts[0])^,Length(has_sel_pts),0); {$endregion}

  {Create Arrays------------------------} {$region -fold}
  SetLength(outer_subgraph1,c          );
  SetLength(outer_subgraph2,c          );
  SetLength(outer_subgraph3,c          );
  SetLength(inner_subgraph_,sel_pts_cnt);
  SetLength(sl_pt_subgraph_,sel_pts_cnt); {$endregion}

  {Outer and Inner Subgraph Calc.-------} {$region -fold}
  obj_ind_ptr                :=Unaligned(@obj_ind                [0]);
  fst_lst_sln_obj_pts_ptr    :=Unaligned(@fst_lst_sln_obj_pts    [0]);
  is_point_selected_ptr      :=Unaligned(@is_point_selected      [0]);
  has_sel_pts_ptr            :=Unaligned(@has_sel_pts            [0]);
  sel_pts_inds_ptr           :=Unaligned(@sel_pts_inds           [0]);
  outer_subgraph1_ptr        :=Unaligned(@outer_subgraph1        [0]);
  outer_subgraph2_ptr        :=Unaligned(@outer_subgraph2        [0]);
  outer_subgraph3_ptr        :=Unaligned(@outer_subgraph3        [0]);
  inner_subgraph__ptr        :=Unaligned(@inner_subgraph_        [0]);
  sl_pt_subgraph__ptr        :=Unaligned(@sl_pt_subgraph_        [0]);
  out_or_inn_subgraph_pts_ptr:=Unaligned(@out_or_inn_subgraph_pts[0]);
  for i:=0 to sel_pts_cnt-1 do
    begin
      case (fst_lst_sln_obj_pts_ptr+sel_pts_inds_ptr^)^ of
        0: {Inner  Spline Object Point} {$region -fold}
          begin
            if (is_point_selected_ptr+sel_pts_inds_ptr^-1)^ then
              begin
                {Inner Subgraph Calc.}
                {--------------------}//(out_or_inn_subgraph_pts_ptr+sel_pts_inds_ptr^-1)^:= 2;
                {--------------------}(out_or_inn_subgraph_pts_ptr+sel_pts_inds_ptr^+0)^:= 2;
                {--------------------}inner_subgraph__ptr^.first_point                  := 00000000000+sel_pts_inds_ptr^-1;
                {--------------------}inner_subgraph__ptr^.last_point                   := 00000000000+sel_pts_inds_ptr^+0;
                {--------------------}inner_subgraph__ptr^.obj_ind                      :=(obj_ind_ptr+sel_pts_inds_ptr^+0)^;
                case (has_sel_pts_ptr+inner_subgraph__ptr^.obj_ind)^ of
                  0: (has_sel_pts_ptr+inner_subgraph__ptr^.obj_ind)^:=2;
                  1: (has_sel_pts_ptr+inner_subgraph__ptr^.obj_ind)^:=3;
                  2: (has_sel_pts_ptr+inner_subgraph__ptr^.obj_ind)^:=2;
                  3: (has_sel_pts_ptr+inner_subgraph__ptr^.obj_ind)^:=3;
                end;
                Inc(inner_subgraph__ptr);
                if (not (is_point_selected_ptr+sel_pts_inds_ptr^+1)^) then
                  begin
                    {Outer Subgraph 3 Calc.}
                    {--------------------}(out_or_inn_subgraph_pts_ptr+sel_pts_inds_ptr^+1)^:= 1;
                    {--------------------}(out_or_inn_subgraph_pts_ptr+sel_pts_inds_ptr^+0)^:= 1;
                    {--------------------}outer_subgraph3_ptr^.first_point                  := 00000000000+sel_pts_inds_ptr^+1;
                    {--------------------}outer_subgraph3_ptr^.last_point                   := 00000000000+sel_pts_inds_ptr^+0;
                    {--------------------}outer_subgraph3_ptr^.obj_ind                      :=(obj_ind_ptr+sel_pts_inds_ptr^+0)^;
                    case (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^ of
                      0: (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^:=1;
                      1: (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^:=1;
                      2: (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^:=3;
                      3: (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^:=3;
                    end;
                    Inc(outer_subgraph3_ptr);
                  end;
              end
            else
              begin
                if (is_point_selected_ptr+sel_pts_inds_ptr^+1)^ then
                  begin
                    {Outer Subgraph 3 Calc.}
                    {--------------------}(out_or_inn_subgraph_pts_ptr+sel_pts_inds_ptr^-1)^:= 1;
                    {--------------------}(out_or_inn_subgraph_pts_ptr+sel_pts_inds_ptr^+0)^:= 1;
                    {--------------------}outer_subgraph3_ptr^.first_point                  := 00000000000+sel_pts_inds_ptr^-1;
                    {--------------------}outer_subgraph3_ptr^.last_point                   := 00000000000+sel_pts_inds_ptr^+0;
                    {--------------------}outer_subgraph3_ptr^.obj_ind                      :=(obj_ind_ptr+sel_pts_inds_ptr^+0)^;
                    case (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^ of
                      0: (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^:=1;
                      1: (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^:=1;
                      2: (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^:=3;
                      3: (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^:=3;
                    end;
                    Inc(outer_subgraph3_ptr);
                  end
                else
                  begin
                    {Outer Subgraph 1,2 Calc.}
                    {--------------------}(out_or_inn_subgraph_pts_ptr+sel_pts_inds_ptr^-1)^:= 1;
                    {--------------------}(out_or_inn_subgraph_pts_ptr+sel_pts_inds_ptr^+0)^:= 1;
                    {--------------------}(out_or_inn_subgraph_pts_ptr+sel_pts_inds_ptr^+1)^:= 1;
                    {--------------------}outer_subgraph1_ptr^.first_point                  := 00000000000+sel_pts_inds_ptr^-1;
                    {--------------------}outer_subgraph1_ptr^.last_point                   := 00000000000+sel_pts_inds_ptr^+0;
                    {--------------------}outer_subgraph1_ptr^.obj_ind                      :=(obj_ind_ptr+sel_pts_inds_ptr^+0)^;
                    {--------------------}outer_subgraph2_ptr^.first_point                  := 00000000000+sel_pts_inds_ptr^+1;
                    {--------------------}outer_subgraph2_ptr^.last_point                   := 00000000000+sel_pts_inds_ptr^+0;
                    {--------------------}outer_subgraph2_ptr^.obj_ind                      :=(obj_ind_ptr+sel_pts_inds_ptr^+0)^;
                    case (has_sel_pts_ptr+outer_subgraph2_ptr^.obj_ind)^ of
                      0: (has_sel_pts_ptr+outer_subgraph2_ptr^.obj_ind)^:=1;
                      1: (has_sel_pts_ptr+outer_subgraph2_ptr^.obj_ind)^:=1;
                      2: (has_sel_pts_ptr+outer_subgraph2_ptr^.obj_ind)^:=3;
                      3: (has_sel_pts_ptr+outer_subgraph2_ptr^.obj_ind)^:=3;
                    end;
                    Inc(outer_subgraph1_ptr);
                    Inc(outer_subgraph2_ptr);
                  end;
              end;
            //Inc(sel_pts_inds_ptr);
          end; {$endregion}
        1: {First  Spline Object Point} {$region -fold}
          begin
            if (not (is_point_selected_ptr+sel_pts_inds_ptr^+1)^) then
              begin
                {Outer Subgraph 3 Calc.}
                {--------------------}(out_or_inn_subgraph_pts_ptr+sel_pts_inds_ptr^+1)^:= 1;
                {--------------------}(out_or_inn_subgraph_pts_ptr+sel_pts_inds_ptr^+0)^:= 1;
                {--------------------}outer_subgraph3_ptr^.first_point                  := 00000000000+sel_pts_inds_ptr^+1;
                {--------------------}outer_subgraph3_ptr^.last_point                   := 00000000000+sel_pts_inds_ptr^+0;
                {--------------------}outer_subgraph3_ptr^.obj_ind                      :=(obj_ind_ptr+sel_pts_inds_ptr^+0)^;
                case (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^ of
                  0: (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^:=1;
                  1: (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^:=1;
                  2: (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^:=3;
                  3: (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^:=3;
                end;
                Inc(outer_subgraph3_ptr);
              end
            else
              begin
                {Inner Subgraph Calc.}
                {--------------------}(out_or_inn_subgraph_pts_ptr+sel_pts_inds_ptr^+1)^:= 2;
                {--------------------}(out_or_inn_subgraph_pts_ptr+sel_pts_inds_ptr^+0)^:= 2;
                {--------------------}inner_subgraph__ptr^.first_point                  := 00000000000+sel_pts_inds_ptr^+1;
                {--------------------}inner_subgraph__ptr^.last_point                   := 00000000000+sel_pts_inds_ptr^+0;
                {--------------------}inner_subgraph__ptr^.obj_ind                      :=(obj_ind_ptr+sel_pts_inds_ptr^+0)^;
                case (has_sel_pts_ptr+inner_subgraph__ptr^.obj_ind)^ of
                  0: (has_sel_pts_ptr+inner_subgraph__ptr^.obj_ind)^:=2;
                  1: (has_sel_pts_ptr+inner_subgraph__ptr^.obj_ind)^:=3;
                  2: (has_sel_pts_ptr+inner_subgraph__ptr^.obj_ind)^:=2;
                  3: (has_sel_pts_ptr+inner_subgraph__ptr^.obj_ind)^:=3;
                end;
                Inc(inner_subgraph__ptr);
              end;
            //Inc(sel_pts_inds_ptr);
          end; {$endregion}
        2: {Last   Spline Object Point} {$region -fold}
          begin
            if (is_point_selected_ptr+sel_pts_inds_ptr^-1)^ then
              begin
                {Inner Subgraph Calc.}
                {--------------------}(out_or_inn_subgraph_pts_ptr+sel_pts_inds_ptr^-1)^:=2;
                {--------------------}(out_or_inn_subgraph_pts_ptr+sel_pts_inds_ptr^+0)^:=2;
                {--------------------}inner_subgraph__ptr^.first_point                  :=000000000000+sel_pts_inds_ptr^-1;
                {--------------------}inner_subgraph__ptr^.last_point                   :=000000000000+sel_pts_inds_ptr^+0;
                {--------------------}inner_subgraph__ptr^.obj_ind                      :=(obj_ind_ptr+sel_pts_inds_ptr^+0)^;
                case (has_sel_pts_ptr+inner_subgraph__ptr^.obj_ind)^ of
                  0: (has_sel_pts_ptr+inner_subgraph__ptr^.obj_ind)^:=2;
                  1: (has_sel_pts_ptr+inner_subgraph__ptr^.obj_ind)^:=3;
                  2: (has_sel_pts_ptr+inner_subgraph__ptr^.obj_ind)^:=2;
                  3: (has_sel_pts_ptr+inner_subgraph__ptr^.obj_ind)^:=3;
                end;
                Inc(inner_subgraph__ptr);
              end
            else
              begin
                {Outer Subgraph 3 Calc.}
                {--------------------}(out_or_inn_subgraph_pts_ptr+sel_pts_inds_ptr^-1)^:=1;
                {--------------------}(out_or_inn_subgraph_pts_ptr+sel_pts_inds_ptr^+0)^:=1;
                {--------------------}outer_subgraph3_ptr^.first_point                  :=000000000000+sel_pts_inds_ptr^-1;
                {--------------------}outer_subgraph3_ptr^.last_point                   :=000000000000+sel_pts_inds_ptr^+0;
                {--------------------}outer_subgraph3_ptr^.obj_ind                      :=(obj_ind_ptr+sel_pts_inds_ptr^+0)^;
                case (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^ of
                  0: (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^:=1;
                  1: (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^:=1;
                  2: (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^:=3;
                  3: (has_sel_pts_ptr+outer_subgraph3_ptr^.obj_ind)^:=3;
                end;
                Inc(outer_subgraph3_ptr);
              end;
            //Inc(sel_pts_inds_ptr);
          end; {$endregion}
        3: {Single Spline Object Point} {$region -fold}
          begin
             {--------------}(out_or_inn_subgraph_pts_ptr+sel_pts_inds_ptr^+0)^:=2;
             {--------------}sl_pt_subgraph__ptr^.point                        :=000000000000+sel_pts_inds_ptr^;
             {--------------}sl_pt_subgraph__ptr^.obj_ind                      :=(obj_ind_ptr+sel_pts_inds_ptr^)^;
            (has_sel_pts_ptr+sl_pt_subgraph__ptr^.obj_ind)^:=4;
            Inc(sl_pt_subgraph__ptr);
            //Inc(sel_pts_inds_ptr);
          end; {$endregion}
      end;
      Inc(sel_pts_inds_ptr);
    end; {$endregion}

  {Edges Count--------------------------} {$region -fold}
  outer_subgraph1_eds_cnt:=PEdge(outer_subgraph1_ptr)-PEdge(@outer_subgraph1[0]);
  outer_subgraph2_eds_cnt:=PEdge(outer_subgraph2_ptr)-PEdge(@outer_subgraph2[0]);
  outer_subgraph3_eds_cnt:=PEdge(outer_subgraph3_ptr)-PEdge(@outer_subgraph3[0]);
  inner_subgraph__eds_cnt:=PEdge(inner_subgraph__ptr)-PEdge(@inner_subgraph_[0]);
  sl_pt_subgraph__eds_cnt:=PSlPt(sl_pt_subgraph__ptr)-PSlPt(@sl_pt_subgraph_[0]); {$endregion}

  {Count of Splines with Selected Points} {$region -fold}
  sln_with_sel_pts_cnt:=ArrNzItCnt(has_sel_pts,4); {$endregion}

  {Selected Points Rectangle Calc.------} {$region -fold}
  sel_pts_rct:=PtsRngIndsRctCalc
  (
    pts,
    sel_pts_inds,
    sel_pts_cnt
  );
  with sel_pts_rct do
    begin
      left  :=sel_pts_rct.left  -{32}50+srf_var.world_axis_shift.x;
      top   :=sel_pts_rct.top   -{32}50+srf_var.world_axis_shift.y;
      right :=sel_pts_rct.right +{32}50+srf_var.world_axis_shift.x;
      bottom:=sel_pts_rct.bottom+{32}50+srf_var.world_axis_shift.y;
      width :=right-left;
      height:=bottom-top;
    end;{$endregion}

  {Minimal Index of Selected Spline-----} {$region -fold}
  f_arr:=Nil;
  f_arr:=TColorArr.Create
  (
    obj_var.Min9(obj_var.curve_inds_obj_arr,outer_subgraph1,obj_var.obj_cnt-1,outer_subgraph1_eds_cnt),
    obj_var.Min9(obj_var.curve_inds_obj_arr,outer_subgraph2,obj_var.obj_cnt-1,outer_subgraph2_eds_cnt),
    obj_var.Min9(obj_var.curve_inds_obj_arr,outer_subgraph3,obj_var.obj_cnt-1,outer_subgraph3_eds_cnt),
    obj_var.Min9(obj_var.curve_inds_obj_arr,inner_subgraph_,obj_var.obj_cnt-1,inner_subgraph__eds_cnt),
    obj_var.Min9(obj_var.curve_inds_obj_arr,sl_pt_subgraph_,obj_var.obj_cnt-1,sl_pt_subgraph__eds_cnt)
  );
  sel_obj_min_ind:=Min5(f_arr,obj_var.obj_cnt-1,5); {$endregion}

end; {$endregion}
procedure TSelPts.UnselectedPtsCalc0(constref fst_lst_sln_obj_pts:TEnum0Arr; var pts:TPtPosFArr; constref pvt_pos_curr,pvt_pos_prev:TPtPosF);         {$ifdef Linux}[local];{$endif} {$region -fold}
var
  pts_ptr                : PPtPosF;
  selected_pts_inds_ptr  : PInteger;
  fst_lst_sln_obj_pts_ptr: PByte;
  is_pt_selected_ptr     : PByteBool;
  i,n1,n2                : integer;
begin

  {Misc. Precalc.----------------------------------------} {$region -fold}
  n1:=Trunc(pvt_pos_curr.x)-Trunc(pvt_pos_prev.x);
  n2:=Trunc(pvt_pos_curr.y)-Trunc(pvt_pos_prev.y); {$endregion}

  {Calculation Of Inner Subgraph Points On Unselect Pivot} {$region -fold}
  {2 alternative records of the same code block}
  {1.} {$region -fold}
  {for i:=0 to sel_pts_cnt-1 do
    case fst_lst_sln_obj_pts[sel_pts_inds[i]] of
      0: {Inner  Spline Object Point} {$region -fold}
        if is_point_selected[sel_pts_inds[i]-1] and
           is_point_selected[sel_pts_inds[i]+1] then
          begin
            pts[sel_pts_inds[i]].x+=n1;
            pts[sel_pts_inds[i]].y+=n2;
          end; {$endregion}
      1: {First  Spline Object Point} {$region -fold}
        if is_point_selected[sel_pts_inds[i]+1] then
          begin
            pts[sel_pts_inds[i]].x+=n1;
            pts[sel_pts_inds[i]].y+=n2;
          end; {$endregion}
      2: {Last   Spline Object Point} {$region -fold}
        if is_point_selected[sel_pts_inds[i]-1] then
          begin
            pts[sel_pts_inds[i]].x+=n1;
            pts[sel_pts_inds[i]].y+=n2;
          end; {$endregion}
      3: {Single Spline Object Point} {$region -fold}
        begin
          pts[sel_pts_inds[i]].x+=n1;
          pts[sel_pts_inds[i]].y+=n2;
        end; {$endregion}
    end;} {$endregion}
  {2.} {$region -fold}
  pts_ptr                :=Unaligned(@pts                [0]);
  fst_lst_sln_obj_pts_ptr:=Unaligned(@fst_lst_sln_obj_pts[0]);
  is_pt_selected_ptr     :=Unaligned(@is_point_selected  [0]);
  selected_pts_inds_ptr  :=Unaligned(@sel_pts_inds       [0]);
  for i:=0 to sel_pts_cnt-1 do
    begin
      case (fst_lst_sln_obj_pts_ptr+selected_pts_inds_ptr^)^ of
        0: {Inner  Spline Object Point} {$region -fold}
          if (is_pt_selected_ptr+selected_pts_inds_ptr^-1)^ and
             (is_pt_selected_ptr+selected_pts_inds_ptr^+1)^ then
            begin
              (pts_ptr+selected_pts_inds_ptr^)^.x+=n1;
              (pts_ptr+selected_pts_inds_ptr^)^.y+=n2;
            end; {$endregion}
        1: {First  Spline Object Point} {$region -fold}
          if (is_pt_selected_ptr+selected_pts_inds_ptr^+1)^ then
            begin
              (pts_ptr+selected_pts_inds_ptr^)^.x+=n1;
              (pts_ptr+selected_pts_inds_ptr^)^.y+=n2;
            end; {$endregion}
        2: {Last   Spline Object Point} {$region -fold}
          if (is_pt_selected_ptr+selected_pts_inds_ptr^-1)^ then
            begin
              (pts_ptr+selected_pts_inds_ptr^)^.x+=n1;
              (pts_ptr+selected_pts_inds_ptr^)^.y+=n2;
            end; {$endregion}
        3: {Single Spline Object Point} {$region -fold}
          begin
            (pts_ptr+selected_pts_inds_ptr^)^.x+=n1;
            (pts_ptr+selected_pts_inds_ptr^)^.y+=n2;
          end; {$endregion}
      end;
      Inc(selected_pts_inds_ptr);
    end; {$endregion} {$endregion}

end; {$endregion}
procedure TSelPts.UnselectedPtsCalc1(constref fst_lst_sln_obj_pts:TEnum0Arr; var pts:TPtPosFArr; constref pvt_pos_curr,pvt_pos_prev:TPtPosF);         {$ifdef Linux}[local];{$endif} {$region -fold}
var
  outer_subgraph1_ptr: PEdge;
  outer_subgraph2_ptr: PEdge;
  outer_subgraph3_ptr: PEdge;
  pts_ptr            : PPtPosF;
  i,n1,n2            : integer;
begin

  {Misc. Precalc.----------------------------------------} {$region -fold}
  n1:=Trunc(pvt_pos_curr.x)-Trunc(pvt_pos_prev.x);
  n2:=Trunc(pvt_pos_curr.y)-Trunc(pvt_pos_prev.y); {$endregion}

  {Calculation Of Inner Subgraph Points On Unselect Pivot} {$region -fold}
  pts_ptr:=Unaligned(@pts[0]);
  if (outer_subgraph1_eds_cnt>0) then
    begin
      outer_subgraph1_ptr:=Unaligned(@outer_subgraph1[0]);
      for i:=0 to  outer_subgraph1_eds_cnt-1 do
        begin
          (pts_ptr+outer_subgraph1_ptr^.last_point)^.x+=n1;
          (pts_ptr+outer_subgraph1_ptr^.last_point)^.y+=n2;
          Inc     (outer_subgraph1_ptr);
        end;
    end;
  if (outer_subgraph3_eds_cnt>0) then
    begin
      outer_subgraph3_ptr:=Unaligned(@outer_subgraph3[0]);
      for i:=0 to  outer_subgraph3_eds_cnt-1 do
        begin
          (pts_ptr+outer_subgraph3_ptr^.last_point)^.x+=n1;
          (pts_ptr+outer_subgraph3_ptr^.last_point)^.y+=n2;
          Inc     (outer_subgraph3_ptr);
        end;
    end; {$endregion}

end; {$endregion}
procedure TSelPts.SelPtsIndsToFalse;                                                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  selected_pts_inds_ptr      : PInteger;
  is_point_selected_ptr      : PByteBool;
  out_or_inn_subgraph_pts_ptr: PByte;
  i                          : integer;
begin
  {2 alternative records of the same code block}
  {1.} {$region -fold}
  {for i:=0 to sel_pts_cnt-1 do
    begin
      out_or_inn_subgraph_pts[sel_pts_inds[i]]:=0
      is_point_selected      [sel_pts_inds[i]]:=False;
    end;} {$endregion}
  {2.} {$region -fold}
  is_point_selected_ptr:=Unaligned(@is_point_selected[0]);
  selected_pts_inds_ptr:=Unaligned(@sel_pts_inds     [0]);
  out_or_inn_subgraph_pts_ptr:=Unaligned(@out_or_inn_subgraph_pts[0]);
  for i:=0 to sel_pts_cnt-1 do
    begin
      (out_or_inn_subgraph_pts_ptr+selected_pts_inds_ptr^)^:=0;
      (is_point_selected_ptr      +selected_pts_inds_ptr^)^:=False;
      Inc(selected_pts_inds_ptr);
    end; {$endregion}
end; {$endregion}
procedure TSelPts.DuplicatedPtsCalc;                                                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
{var
  i,j,k,v,m1,m2: integer;}
begin
  {
  v:=100;
  m1:=5;
  m2:=5;
  duplicated_pts_count:=0;
  for k:=0 to spline_pts_count-1 do
    is_point_duplicated[k]:=False;
  with F_MainForm.Canvas do
    begin
      Pen.Mode :=pmCopy;
      Pen.Color:=clYellow;
      for i:=0 to m1 do
        for j:=0 to m2 do
          for k:=0 to spline_pts_count-1 do
            if (spline_pts[k].x>i*v) and (spline_pts[k].x<=(i+1)*v) and
               (spline_pts[k].y>j*v) and (spline_pts[k].y<=(j+1)*v) then
              if (not is_point_duplicated[k]) then
                begin
                  is_point_duplicated[k]:=True;
                  Rectangle(spline_pts[k].x-4,
                            spline_pts[k].y-4,
                            spline_pts[k].x+5,
                            spline_pts[k].y+5);
                  Inc(duplicated_pts_count);
                end;
    end;
  }
  {
  for i:=0 to spline_pts_count-1 do
    for j:=i+1 to spline_pts_count do
      if (not is_point_duplicated[i]) and
         (not is_point_duplicated[j]) then
        if (spline_pts[i].x=spline_pts[j].x) then
          if (spline_pts[i].y=spline_pts[j].y) then
            begin
              is_point_duplicated[i]:=True;
              is_point_duplicated[j]:=True;
              Break;
            end;
  }
end; {$endregion}
procedure TSelPts.AdvancedClipCalc(pts:TPtPosFArr; pts_cnt:TColor; is_pt_marked:TBool1Arr);                                                           {$ifdef Linux}[local];{$endif} {$region -fold}
{var
  i,m,clip_rad: integer;}
begin
  {m:=clip_rad*clip_rad;
  for i:=0 to pts_count do
    if (pts[i].x-X)*(pts[i].x-X)+
       (pts[i].y-Y)*(pts[i].y-Y)>=m then
      begin

      end;}
end; {$endregion}
procedure TSelPts.DuplicatedPtsToBmp;                                                                                                         inline; {$ifdef Linux}[local];{$endif} {$region -fold}
{var
  i: integer;}
begin
  {
  with F_MainForm.Canvas do
    begin
      Pen.Mode :=pmCopy;
      Pen.Color:=clFuchsia;
      for i:=0 to spline_pts_count-1 do
        if is_point_duplicated[i] then
          Rectangle(spline_pts[i].x-4,
                    spline_pts[i].y-4,
                    spline_pts[i].x+5,
                    spline_pts[i].y+5);
    end;
  }
end; {$endregion}
procedure TSelPts.OuterSubgraphToBmp(x,y:integer; constref pvt:TPtPosF; var pts:TPtPosFArr; constref bmp_dst_ptr:PInteger; constref rct_clp:TPtRect); {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rct1,rct2          : TPtRect;
  pts_ptr            : PPtPosF;
  pts_f1,pts_l1      : TPtPosF;
  pts_f2,pts_l2      : TPtPosF;
  pts_f3,pts_l3      : TPtPosF;
  outer_subgraph1_ptr: PEdge;
  outer_subgraph2_ptr: PEdge;
  outer_subgraph3_ptr: PEdge;
  n1,n2              : integer;
  i,j                : integer;
  m1,m2,m3,m4        : integer;
label
  lbl_flood_fill_only;
begin

  if (outer_subgraph1_eds_cnt=0) and
     (outer_subgraph3_eds_cnt=0) then
    Exit;

  outer_subgraph_img.bmp_dst_ptr:=bmp_dst_ptr;

  if fill_bmp_only then
    goto lbl_flood_fill_only;

  {Misc. Precalc.------------------} {$region -fold}
  n1:=x-Trunc(pvt.x);
  n2:=y-Trunc(pvt.y); {$endregion}

  {Set Drawing Bounds(Inner Window)} {$region -fold}
  with rct_clp do
    begin
      m1:=left  +outer_subgraph_img.grid_pt_rad;
      m2:=top   +outer_subgraph_img.grid_pt_rad;
      m3:=right -outer_subgraph_img.grid_pt_rad-1;
      m4:=bottom-outer_subgraph_img.grid_pt_rad-1;
    end;
  rct1:=PtRct(m1,m2,m3,m4);{$endregion}

  {Clear Arrays--------------------} {$region -fold}
  with outer_subgraph_img,local_prop do
    begin
      ArrClear(ln_arr0,rct_clp,ln_arr_width);
      ArrClear(ln_arr2,rct_clp);
    end; {$endregion}

  {Drawing Of Outer Subgraph Lines-} {$region -fold}
  with outer_subgraph_img do
    case local_prop.clp_stl of
      (csClippedEdges1 ): {Clipped Edges 1(Slow  )} {$region -fold}
        begin
          {Drawing Of Outer Subgraph 1,2} {$region -fold}
          if (outer_subgraph1_eds_cnt>0) then
            begin
              {2 alternative records of the same code block}
              {1.} {$region -fold}
              {for i:=0 to outer_subgraph1_eds_cnt-1 do
                begin
                  pts[outer_subgraph1[i].last_point].x+=n1;
                  pts[outer_subgraph1[i].last_point].y+=n2;
                  ClippedLine1
                  (
                    Trunc(pts[outer_subgraph1[i].first_point].x+srf_var.world_axis_shift.x),
                    Trunc(pts[outer_subgraph1[i].first_point].y+srf_var.world_axis_shift.y),
                    Trunc(pts[outer_subgraph1[i].last_point ].x+srf_var.world_axis_shift.x),
                    Trunc(pts[outer_subgraph1[i].last_point ].y+srf_var.world_axis_shift.y),
                    PtRct(m1,m2,m3,m4),
                    Unaligned(@LineSME),
                    Nil,
                    Nil
                  );
                  ClippedLine1
                  (
                    Trunc(pts[outer_subgraph2[i].first_point].x+srf_var.world_axis_shift.x),
                    Trunc(pts[outer_subgraph2[i].first_point].y+srf_var.world_axis_shift.y),
                    Trunc(pts[outer_subgraph2[i].last_point ].x+srf_var.world_axis_shift.x),
                    Trunc(pts[outer_subgraph2[i].last_point ].y+srf_var.world_axis_shift.y),
                    PtRct(m1,m2,m3,m4),
                    Unaligned(@LineSME),
                    Nil,
                    Nil
                  );
                end;} {$endregion}
              {2.} {$region -fold}
              pts_ptr            :=Unaligned(@pts            [0]);
              outer_subgraph1_ptr:=Unaligned(@outer_subgraph1[0]);
              outer_subgraph2_ptr:=Unaligned(@outer_subgraph2[0]);
              for i:=0 to outer_subgraph1_eds_cnt-1 do
                begin
                  (pts_ptr+outer_subgraph1_ptr^.last_point)^.x+=n1;
                  (pts_ptr+outer_subgraph1_ptr^.last_point)^.y+=n2;
                  ClippedLine1
                  (
                    Trunc((pts_ptr+outer_subgraph1_ptr^.first_point)^.x+srf_var.world_axis_shift.x),
                    Trunc((pts_ptr+outer_subgraph1_ptr^.first_point)^.y+srf_var.world_axis_shift.y),
                    Trunc((pts_ptr+outer_subgraph1_ptr^.last_point )^.x+srf_var.world_axis_shift.x),
                    Trunc((pts_ptr+outer_subgraph1_ptr^.last_point )^.y+srf_var.world_axis_shift.y),
                    PtRct(m1,m2,m3,m4),
                    Unaligned(@LineSME),
                    Nil,
                    Nil
                  );
                  ClippedLine1
                  (
                    Trunc((pts_ptr+outer_subgraph2_ptr^.first_point)^.x+srf_var.world_axis_shift.x),
                    Trunc((pts_ptr+outer_subgraph2_ptr^.first_point)^.y+srf_var.world_axis_shift.y),
                    Trunc((pts_ptr+outer_subgraph2_ptr^.last_point )^.x+srf_var.world_axis_shift.x),
                    Trunc((pts_ptr+outer_subgraph2_ptr^.last_point )^.y+srf_var.world_axis_shift.y),
                    PtRct(m1,m2,m3,m4),
                    Unaligned(@LineSME),
                    Nil,
                    Nil
                  );
                  Inc(outer_subgraph1_ptr);
                  Inc(outer_subgraph2_ptr);
                end; {$endregion}
            end; {$endregion}
          {Drawing Of Outer Subgraph 3  } {$region -fold}
          if (outer_subgraph3_eds_cnt>0) then
            begin
              {2 alternative records of the same code block}
              {1.} {$region -fold}
              {for i:=0 to outer_subgraph3_eds_cnt-1 do
                begin
                  pts[outer_subgraph3[i].last_point].x+=n1;
                  pts[outer_subgraph3[i].last_point].y+=n2;
                  ClippedLine1
                  (
                    Trunc(pts[outer_subgraph3[i].first_point].x+srf_var.world_axis_shift.x),
                    Trunc(pts[outer_subgraph3[i].first_point].y+srf_var.world_axis_shift.y),
                    Trunc(pts[outer_subgraph3[i].last_point ].x+srf_var.world_axis_shift.x),
                    Trunc(pts[outer_subgraph3[i].last_point ].y+srf_var.world_axis_shift.y),
                    PtRct(m1,m2,m3,m4),
                    Unaligned(@LineSME),
                    Nil,
                    Nil
                  );
                end;} {$endregion}
              {2.} {$region -fold}
              pts_ptr            :=Unaligned(@pts            [0]);
              outer_subgraph3_ptr:=Unaligned(@outer_subgraph3[0]);
              for i:=0 to outer_subgraph3_eds_cnt-1 do
                begin
                  (pts_ptr+outer_subgraph3_ptr^.last_point)^.x+=n1;
                  (pts_ptr+outer_subgraph3_ptr^.last_point)^.y+=n2;
                  ClippedLine1
                  (
                    Trunc((pts_ptr+outer_subgraph3_ptr^.first_point)^.x+srf_var.world_axis_shift.x),
                    Trunc((pts_ptr+outer_subgraph3_ptr^.first_point)^.y+srf_var.world_axis_shift.y),
                    Trunc((pts_ptr+outer_subgraph3_ptr^.last_point )^.x+srf_var.world_axis_shift.x),
                    Trunc((pts_ptr+outer_subgraph3_ptr^.last_point )^.y+srf_var.world_axis_shift.y),
                    PtRct(m1,m2,m3,m4),
                    Unaligned(@LineSME),
                    Nil,
                    Nil
                  );
                Inc(outer_subgraph3_ptr);
              end; {$endregion}
            end; {$endregion}
        end; {$endregion}
      (csClippedEdges2 ): {Clipped Edges 2(Slow  )} {$region -fold}
        begin
          {Drawing Of Outer Subgraph 1,2} {$region -fold}
          if (outer_subgraph1_eds_cnt>0) then
            begin
              {2 alternative records of the same code block}
              {1.} {$region -fold}
              {for i:=0 to outer_subgraph1_eds_cnt-1 do
                begin
                  pts[outer_subgraph1[i].last_point].x+=n1;
                  pts[outer_subgraph1[i].last_point].y+=n2;
                  ClippedLine2
                  (
                    Trunc(pts[outer_subgraph1[i].first_point].x+srf_var.world_axis_shift.x),
                    Trunc(pts[outer_subgraph1[i].first_point].y+srf_var.world_axis_shift.y),
                    Trunc(pts[outer_subgraph1[i].last_point ].x+srf_var.world_axis_shift.x),
                    Trunc(pts[outer_subgraph1[i].last_point ].y+srf_var.world_axis_shift.y),
                    PtRct(m1,m2,m3,m4),
                    Unaligned(@LineSME),
                    Nil,
                    Nil
                  );
                  ClippedLine2
                  (
                    Trunc(pts[outer_subgraph2[i].first_point].x+srf_var.world_axis_shift.x),
                    Trunc(pts[outer_subgraph2[i].first_point].y+srf_var.world_axis_shift.y),
                    Trunc(pts[outer_subgraph2[i].last_point ].x+srf_var.world_axis_shift.x),
                    Trunc(pts[outer_subgraph2[i].last_point ].y+srf_var.world_axis_shift.y),
                    PtRct(m1,m2,m3,m4),
                    Unaligned(@LineSME),
                    Nil,
                    Nil
                  );
                end;} {$endregion}
              {2.} {$region -fold}
              pts_ptr            :=Unaligned(@pts            [0]);
              outer_subgraph1_ptr:=Unaligned(@outer_subgraph1[0]);
              outer_subgraph2_ptr:=Unaligned(@outer_subgraph2[0]);
              for i:=0 to outer_subgraph1_eds_cnt-1 do
                begin
                  (pts_ptr+outer_subgraph1_ptr^.last_point)^.x+=n1;
                  (pts_ptr+outer_subgraph1_ptr^.last_point)^.y+=n2;
                  ClippedLine2
                  (
                    Trunc((pts_ptr+outer_subgraph1_ptr^.first_point)^.x+srf_var.world_axis_shift.x),
                    Trunc((pts_ptr+outer_subgraph1_ptr^.first_point)^.y+srf_var.world_axis_shift.y),
                    Trunc((pts_ptr+outer_subgraph1_ptr^.last_point )^.x+srf_var.world_axis_shift.x),
                    Trunc((pts_ptr+outer_subgraph1_ptr^.last_point )^.y+srf_var.world_axis_shift.y),
                    PtRct(m1,m2,m3,m4),
                    Unaligned(@LineSME),
                    Nil,
                    Nil
                  );
                  ClippedLine2
                  (
                    Trunc((pts_ptr+outer_subgraph2_ptr^.first_point)^.x+srf_var.world_axis_shift.x),
                    Trunc((pts_ptr+outer_subgraph2_ptr^.first_point)^.y+srf_var.world_axis_shift.y),
                    Trunc((pts_ptr+outer_subgraph2_ptr^.last_point )^.x+srf_var.world_axis_shift.x),
                    Trunc((pts_ptr+outer_subgraph2_ptr^.last_point )^.y+srf_var.world_axis_shift.y),
                    PtRct(m1,m2,m3,m4),
                    Unaligned(@LineSME),
                    Nil,
                    Nil
                  );
                  Inc(outer_subgraph1_ptr);
                  Inc(outer_subgraph2_ptr);
                end; {$endregion}
            end; {$endregion}
          {Drawing Of Outer Subgraph 3  } {$region -fold}
          if (outer_subgraph3_eds_cnt>0) then
            begin
              {2 alternative records of the same code block}
              {1.} {$region -fold}
              {for i:=0 to outer_subgraph3_eds_cnt-1 do
                begin
                  pts[outer_subgraph3[i].last_point].x+=n1;
                  pts[outer_subgraph3[i].last_point].y+=n2;
                  ClippedLine2
                  (
                    Trunc(pts[outer_subgraph3[i].first_point].x+srf_var.world_axis_shift.x),
                    Trunc(pts[outer_subgraph3[i].first_point].y+srf_var.world_axis_shift.y),
                    Trunc(pts[outer_subgraph3[i].last_point ].x+srf_var.world_axis_shift.x),
                    Trunc(pts[outer_subgraph3[i].last_point ].y+srf_var.world_axis_shift.y),
                    PtRct(m1,m2,m3,m4),
                    Unaligned(@LineSME),
                    Nil,
                    Nil
                  );
                end;} {$endregion}
              {2.} {$region -fold}
              pts_ptr            :=Unaligned(@pts            [0]);
              outer_subgraph3_ptr:=Unaligned(@outer_subgraph3[0]);
              for i:=0 to outer_subgraph3_eds_cnt-1 do
                begin
                  (pts_ptr+outer_subgraph3_ptr^.last_point)^.x+=n1;
                  (pts_ptr+outer_subgraph3_ptr^.last_point)^.y+=n2;
                  ClippedLine2
                  (
                    Trunc((pts_ptr+outer_subgraph3_ptr^.first_point)^.x+srf_var.world_axis_shift.x),
                    Trunc((pts_ptr+outer_subgraph3_ptr^.first_point)^.y+srf_var.world_axis_shift.y),
                    Trunc((pts_ptr+outer_subgraph3_ptr^.last_point )^.x+srf_var.world_axis_shift.x),
                    Trunc((pts_ptr+outer_subgraph3_ptr^.last_point )^.y+srf_var.world_axis_shift.y),
                    PtRct(m1,m2,m3,m4),
                    Unaligned(@LineSME),
                    Nil,
                    Nil
                  );
                Inc(outer_subgraph3_ptr);
              end; {$endregion}
            end; {$endregion}
        end; {$endregion}
      (csRemoveEdges   ): {Remove Edges---(Fast  )} {$region -fold}
        begin
          {Drawing Of Outer Subgraph 1,2} {$region -fold}
          if (outer_subgraph1_eds_cnt>0) then
            begin
              {2 alternative records of the same code block}
              {1.} {$region -fold}
              {for i:=0 to outer_subgraph1_eds_cnt-1 do
                begin
                  pts[outer_subgraph1[i].last_point].x+=n1;
                  pts[outer_subgraph1[i].last_point].y+=n2;
                  pts_f1:=pts[outer_subgraph1[i].first_point];
                  pts_l1:=pts[outer_subgraph1[i].last_point ];
                  if IsPtInRct(PtPosF(pts_f1.x+srf_var.world_axis_shift.x,pts_f3.y+srf_var.world_axis_shift.y),rct1) and
                     IsPtInRct(PtPosF(pts_l1.x+srf_var.world_axis_shift.x,pts_l3.y+srf_var.world_axis_shift.y),rct1) then
                    LineSMN
                    (
                      Trunc(pts_f1.first_point].x+srf_var.world_axis_shift.x),
                      Trunc(pts_f1.first_point].y+srf_var.world_axis_shift.y),
                      Trunc(pts_l1.last_point ].x+srf_var.world_axis_shift.x),
                      Trunc(pts_l1.last_point ].y+srf_var.world_axis_shift.y)
                    );
                  pts_f2:=pts[outer_subgraph2[i].first_point];
                  pts_l2:=pts[outer_subgraph2[i].last_point ];
                  if IsPtInRct(PtPosF(pts_f2.x+srf_var.world_axis_shift.x,pts_f3.y+srf_var.world_axis_shift.y),rct1) and
                     IsPtInRct(PtPosF(pts_l2.x+srf_var.world_axis_shift.x,pts_l3.y+srf_var.world_axis_shift.y),rct1) then
                    LineSMN
                    (
                      Trunc(pts_f2.first_point].x+srf_var.world_axis_shift.x),
                      Trunc(pts_f2.first_point].y+srf_var.world_axis_shift.y),
                      Trunc(pts_l2.last_point ].x+srf_var.world_axis_shift.x),
                      Trunc(pts_l2.last_point ].y+srf_var.world_axis_shift.y)
                    );
                end;} {$endregion}
              {2.} {$region -fold}
              pts_ptr            :=Unaligned(@pts            [0]);
              outer_subgraph1_ptr:=Unaligned(@outer_subgraph1[0]);
              outer_subgraph2_ptr:=Unaligned(@outer_subgraph2[0]);
              for i:=0 to outer_subgraph1_eds_cnt-1 do
                begin
                  (pts_ptr+outer_subgraph1_ptr^.last_point)^.x+=n1;
                  (pts_ptr+outer_subgraph1_ptr^.last_point)^.y+=n2;
                  pts_f1:=(pts_ptr+outer_subgraph1_ptr^.first_point)^;
                  pts_l1:=(pts_ptr+outer_subgraph1_ptr^.last_point )^;
                  if IsPtInRct(PtPosF(pts_f1.x+srf_var.world_axis_shift.x,pts_f1.y+srf_var.world_axis_shift.y),rct1) and
                     IsPtInRct(PtPosF(pts_l1.x+srf_var.world_axis_shift.x,pts_l1.y+srf_var.world_axis_shift.y),rct1) then
                    LineSMN
                    (
                      Trunc(pts_f1.x+srf_var.world_axis_shift.x),
                      Trunc(pts_f1.y+srf_var.world_axis_shift.y),
                      Trunc(pts_l1.x+srf_var.world_axis_shift.x),
                      Trunc(pts_l1.y+srf_var.world_axis_shift.y)
                    );
                  pts_f2:=(pts_ptr+outer_subgraph2_ptr^.first_point)^;
                  pts_l2:=(pts_ptr+outer_subgraph2_ptr^.last_point )^;
                  if IsPtInRct(PtPosF(pts_f2.x+srf_var.world_axis_shift.x,pts_f2.y+srf_var.world_axis_shift.y),rct1) and
                     IsPtInRct(PtPosF(pts_l2.x+srf_var.world_axis_shift.x,pts_l2.y+srf_var.world_axis_shift.y),rct1) then
                    LineSMN
                    (
                      Trunc(pts_f2.x+srf_var.world_axis_shift.x),
                      Trunc(pts_f2.y+srf_var.world_axis_shift.y),
                      Trunc(pts_l2.x+srf_var.world_axis_shift.x),
                      Trunc(pts_l2.y+srf_var.world_axis_shift.y)
                    );
                  Inc(outer_subgraph1_ptr);
                  Inc(outer_subgraph2_ptr);
                end; {$endregion}
            end; {$endregion}
          {Drawing Of Outer Subgraph 3  } {$region -fold}
          if (outer_subgraph3_eds_cnt>0) then
            begin
              {2 alternative records of the same code block}
              {1.} {$region -fold}
              {for i:=0 to outer_subgraph3_eds_cnt-1 do
                begin
                  pts[outer_subgraph3[i].last_point].x+=n1;
                  pts[outer_subgraph3[i].last_point].y+=n2;
                  pts_f3:=pts[outer_subgraph3[i].first_point];
                  pts_l3:=pts[outer_subgraph3[i].last_point ];
                  if IsPtInRct(PtPosF(pts_f3.x+srf_var.world_axis_shift.x,pts_f3.y+srf_var.world_axis_shift.y),rct1) and
                     IsPtInRct(PtPosF(pts_l3.x+srf_var.world_axis_shift.x,pts_l3.y+srf_var.world_axis_shift.y),rct1) then
                    LineSMN
                    (
                      Trunc(pts[outer_subgraph3[i].first_point].x+srf_var.world_axis_shift.x),
                      Trunc(pts[outer_subgraph3[i].first_point].y+srf_var.world_axis_shift.y),
                      Trunc(pts[outer_subgraph3[i].last_point ].x+srf_var.world_axis_shift.x),
                      Trunc(pts[outer_subgraph3[i].last_point ].y+srf_var.world_axis_shift.y)
                    );
                end;} {$endregion}
              {2.} {$region -fold}
              pts_ptr            :=Unaligned(@pts            [0]);
              outer_subgraph3_ptr:=Unaligned(@outer_subgraph3[0]);
              for i:=0 to outer_subgraph3_eds_cnt-1 do
                begin
                  (pts_ptr+outer_subgraph3_ptr^.last_point)^.x+=n1;
                  (pts_ptr+outer_subgraph3_ptr^.last_point)^.y+=n2;
                  pts_f3:=(pts_ptr+outer_subgraph3_ptr^.first_point)^;
                  pts_l3:=(pts_ptr+outer_subgraph3_ptr^.last_point )^;
                  if IsPtInRct(PtPosF(pts_f3.x+srf_var.world_axis_shift.x,pts_f3.y+srf_var.world_axis_shift.y),rct1) and
                     IsPtInRct(PtPosF(pts_l3.x+srf_var.world_axis_shift.x,pts_l3.y+srf_var.world_axis_shift.y),rct1) then
                    LineSMN
                    (
                      Trunc(pts_f3.x+srf_var.world_axis_shift.x),
                      Trunc(pts_f3.y+srf_var.world_axis_shift.y),
                      Trunc(pts_l3.x+srf_var.world_axis_shift.x),
                      Trunc(pts_l3.y+srf_var.world_axis_shift.y)
                    );
                Inc(outer_subgraph3_ptr);
              end; {$endregion}
            end; {$endregion}
        end; {$endregion}
      (csAdvancedClip  ): {Advanced Clip--(Turbo )} {$region -fold}
        begin
          {n:=CheckDensity1(outer_subgraph_f_ln_var.f_ln_arr0,
                            outer_subgraph_f_ln_var.f_ln_arr2,
                            rect_clp.Width,
                            rect_clp.Height);}
        end; {$endregion}
      (csResilientEdges): {Resilient Edges(Unreal)} {$region -fold}
        begin
          {Drawing Of Outer Subgraph 1,2} {$region -fold}
          if (outer_subgraph1_eds_cnt>0) then
            begin
              {2 alternative records of the same code block}
              {1.} {$region -fold}
              {for i:=0 to outer_subgraph1_eds_cnt-1 do
                begin
                  pts[outer_subgraph1[i].last_point].x+=n1;
                  pts[outer_subgraph1[i].last_point].y+=n2;
                  ClippedLine2
                  (
                    Trunc(pts[outer_subgraph1[i].first_point].x+srf_var.world_axis_shift.x),
                    Trunc(pts[outer_subgraph1[i].first_point].y+srf_var.world_axis_shift.y),
                    Trunc(pts[outer_subgraph1[i].last_point ].x+srf_var.world_axis_shift.x),
                    Trunc(pts[outer_subgraph1[i].last_point ].y+srf_var.world_axis_shift.y),
                    PtRct(m1,m2,m3,m4)
                  );
                  LineR
                  (
                    ln_pos.x0,
                    ln_pos.y0,
                    ln_pos.x1,
                    ln_pos.y1,
                    16
                  );
                  ClippedLine2
                  (
                    Trunc(pts[outer_subgraph2[i].first_point].x+srf_var.world_axis_shift.x),
                    Trunc(pts[outer_subgraph2[i].first_point].y+srf_var.world_axis_shift.y),
                    Trunc(pts[outer_subgraph2[i].last_point ].x+srf_var.world_axis_shift.x),
                    Trunc(pts[outer_subgraph2[i].last_point ].y+srf_var.world_axis_shift.y),
                    PtRct(m1,m2,m3,m4)
                  );
                  LineR
                  (
                    ln_pos.x0,
                    ln_pos.y0,
                    ln_pos.x1,
                    ln_pos.y1,
                    16
                  );
                end;} {$endregion}
              {2.} {$region -fold}
              pts_ptr            :=Unaligned(@pts            [0]);
              outer_subgraph1_ptr:=Unaligned(@outer_subgraph1[0]);
              outer_subgraph2_ptr:=Unaligned(@outer_subgraph2[0]);
              for i:=0 to outer_subgraph1_eds_cnt-1 do
                begin
                  (pts_ptr+outer_subgraph1_ptr^.last_point)^.x+=n1;
                  (pts_ptr+outer_subgraph1_ptr^.last_point)^.y+=n2;
                  ClippedLine2
                  (
                    Trunc((pts_ptr+outer_subgraph1_ptr^.first_point)^.x+srf_var.world_axis_shift.x),
                    Trunc((pts_ptr+outer_subgraph1_ptr^.first_point)^.y+srf_var.world_axis_shift.y),
                    Trunc((pts_ptr+outer_subgraph1_ptr^.last_point )^.x+srf_var.world_axis_shift.x),
                    Trunc((pts_ptr+outer_subgraph1_ptr^.last_point )^.y+srf_var.world_axis_shift.y),
                    PtRct(m1,m2,m3,m4)
                  );
                  LineR
                  (
                    ln_pos.x0,
                    ln_pos.y0,
                    ln_pos.x1,
                    ln_pos.y1,
                    bmp_dst_ptr,
                    ln_arr_width,
                    color_info,
                    16
                  );
                  ClippedLine2
                  (
                    Trunc((pts_ptr+outer_subgraph2_ptr^.first_point)^.x+srf_var.world_axis_shift.x),
                    Trunc((pts_ptr+outer_subgraph2_ptr^.first_point)^.y+srf_var.world_axis_shift.y),
                    Trunc((pts_ptr+outer_subgraph2_ptr^.last_point )^.x+srf_var.world_axis_shift.x),
                    Trunc((pts_ptr+outer_subgraph2_ptr^.last_point )^.y+srf_var.world_axis_shift.y),
                    PtRct(m1,m2,m3,m4)
                  );
                  LineR
                  (
                    ln_pos.x0,
                    ln_pos.y0,
                    ln_pos.x1,
                    ln_pos.y1,
                    bmp_dst_ptr,
                    ln_arr_width,
                    color_info,
                    16
                  );
                  Inc(outer_subgraph1_ptr);
                  Inc(outer_subgraph2_ptr);
                end; {$endregion}
            end; {$endregion}
          {Drawing Of Outer Subgraph 3  } {$region -fold}
          if (outer_subgraph3_eds_cnt>0) then
            begin
              {2 alternative records of the same code block}
              {1.} {$region -fold}
              {for i:=0 to outer_subgraph3_eds_cnt-1 do
                begin
                  pts[outer_subgraph3[i].last_point].x+=n1;
                  pts[outer_subgraph3[i].last_point].y+=n2;
                  ClippedLine2
                  (
                    Trunc(pts[outer_subgraph3[i].first_point].x+srf_var.world_axis_shift.x),
                    Trunc(pts[outer_subgraph3[i].first_point].y+srf_var.world_axis_shift.y),
                    Trunc(pts[outer_subgraph3[i].last_point ].x+srf_var.world_axis_shift.x),
                    Trunc(pts[outer_subgraph3[i].last_point ].y+srf_var.world_axis_shift.y),
                    PtRct(m1,m2,m3,m4)
                  );
                  LineR
                  (
                    ln_pos.x0,
                    ln_pos.y0,
                    ln_pos.x1,
                    ln_pos.y1,
                    bmp_dst_ptr,
                    ln_arr_width,
                    color_info,
                    16
                  );
                end;} {$endregion}
              {2.} {$region -fold}
              pts_ptr            :=Unaligned(@pts            [0]);
              outer_subgraph3_ptr:=Unaligned(@outer_subgraph3[0]);
              for i:=0 to outer_subgraph3_eds_cnt-1 do
                begin
                  (pts_ptr+outer_subgraph3_ptr^.last_point)^.x+=n1;
                  (pts_ptr+outer_subgraph3_ptr^.last_point)^.y+=n2;
                  ClippedLine2
                  (
                    Trunc((pts_ptr+outer_subgraph3_ptr^.first_point)^.x+srf_var.world_axis_shift.x),
                    Trunc((pts_ptr+outer_subgraph3_ptr^.first_point)^.y+srf_var.world_axis_shift.y),
                    Trunc((pts_ptr+outer_subgraph3_ptr^.last_point )^.x+srf_var.world_axis_shift.x),
                    Trunc((pts_ptr+outer_subgraph3_ptr^.last_point )^.y+srf_var.world_axis_shift.y),
                    PtRct(m1,m2,m3,m4)
                  );
                  LineR
                  (
                    ln_pos.x0,
                    ln_pos.y0,
                    ln_pos.x1,
                    ln_pos.y1,
                    bmp_dst_ptr,
                    ln_arr_width,
                    color_info,
                    16
                  );
                Inc(outer_subgraph3_ptr);
              end; {$endregion}
            end; {$endregion}
          Exit;
        end; {$endregion}
    end; {$endregion}

  lbl_flood_fill_only:

  {Fill Subgraph Lines-------------} {$region -fold}
  with outer_subgraph_img,local_prop do
    if (clp_stl<>csResilientEdges) then
      begin
        with rct_clp do
          rct2:=PtRct(left+1,top+1,right-1,bottom-1);
        j:=0;
        case eds_bld_stl of
          (dsMonochrome): j:=0;
          (dsAdditive  ): j:=1;
          (dsAlphablend): j:=2;
          (dsInverse   ): j:=3;
          (dsHighlight ): j:=4;
          (dsDarken    ): j:=5;
          (dsGrayscaleR): j:=6;
          (dsGrayscaleG): j:=7;
          (dsGrayscaleB): j:=8;
          (dsMononoise ): j:=9;
        end;
        ArrAdd         (ln_arr0,
                        ln_arr2,
                        rct_clp,
                        ln_arr_width,
                        ln_arr_height);

        {Fill Edges---------} {$region -fold}
        ArrFillProc[j] (ln_arr0,
                        bmp_dst_ptr,
                        ln_arr_width,
                        ln_arr_height,
                        rct_clp,
                        eds_col); {$endregion}

        {Edges Anti-Aliasing} {$region -fold}
        if eds_aa then
          begin
            {ArrClear    (aa_arr1,
                         rct2,
                         ln_arr_width);}
            BorderCalc1 (ln_arr0,
                         aa_arr1,
                         ln_arr_width,
                         ln_arr_width,
                         rct2,
                         aa_nz_arr_items_cnt);
            BorderCalc22(ln_arr0,
                         aa_arr1,
                         aa_arr2,
                         ln_arr_width,
                         ln_arr_width,
                         rct2,
                         aa_line_cnt);
            BorderFill  (aa_arr2,
                         0,
                         0,
                         bmp_dst_ptr,
                         ln_arr_width,
                         aa_line_cnt,
                         eds_col,
                         args,
                         PPDec2Proc[pp_dec_2_proc_ind]);
          end; {$endregion}

      end; {$endregion}

end; {$endregion}
procedure TSelPts.InnerSubgraphToBmp(x,y:integer; constref pvt:TPtPosF; var pts:TPtPosFArr; constref bmp_dst_ptr:PInteger; constref rct_clp:TPtRect); {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rct1,rct2                  : TPtRect;
  pts_ptr                    : PPtPosF;
  pts_f3,pts_l3              : TPtPosF;
  inner_subgraph_ptr         : PEdge;
  out_or_inn_subgraph_pts_ptr: PByte;
  n1,n2                      : integer;
  i,j                        : integer;
  m1,m2,m3,m4                : integer;
label
  lbl_flood_fill_only;
begin

  if (inner_subgraph__eds_cnt=0) then
    Exit;

  inner_subgraph_img.bmp_dst_ptr:=bmp_dst_ptr;

  if fill_bmp_only then
    goto lbl_flood_fill_only;

  {Misc. Precalc.------------------} {$region -fold}
  n1:=Trunc(pvt.x)-Trunc(pvt_var.pvt_origin.x);
  n2:=Trunc(pvt.y)-Trunc(pvt_var.pvt_origin.y);
  {n1:=x-Trunc(pvt.x);
  n2:=y-Trunc(pvt.y);} {$endregion}

  {Set Drawing Bounds(Inner Window)} {$region -fold}
  with rct_clp do
    begin
      m1:=left  +inner_subgraph_img.grid_pt_rad;
      m2:=top   +inner_subgraph_img.grid_pt_rad;
      m3:=right -inner_subgraph_img.grid_pt_rad-1;
      m4:=bottom-inner_subgraph_img.grid_pt_rad-1;
    end;
  rct1:=PtRct(m1,m2,m3,m4); {$endregion}

  {Clear Arrays--------------------} {$region -fold}
  with inner_subgraph_img,local_prop do
    begin
      ArrClear(ln_arr0,rct_clp,ln_arr_width);
      ArrClear(ln_arr2,rct_clp);
    end; {$endregion}

  {Drawing Of Inner Subgraph Lines-} {$region -fold}
  with inner_subgraph_img do
    case local_prop.clp_stl of
      (csClippedEdges1 ): {Clipped Edges 1(Slow  )} {$region -fold}
        if (inner_subgraph__eds_cnt>0) then
          begin
            {2 alternative records of the same code block}
            {1.} {$region -fold}
            {for i:=0 to inner_subgraph__eds_cnt-1 do
              begin
                pts_f3:=(pts[inner_subgraph_[i].first_point]);
                pts_l3:=(pts[inner_subgraph_[i].last_point ]);
                if ((out_or_inn_subgraph_pts[inner_subgraph_[i].first_point])=2) then
                  begin
                    pts_f3.x+=n1;
                    pts_f3.y+=n2;
                  end;
                if ((out_or_inn_subgraph_pts[inner_subgraph_[i].last_point ])=2) then
                  begin
                    pts_l3.x+=n1;
                    pts_l3.y+=n2;
                  end;
                ClippedLine1
                (
                  Trunc(pts_f3.x+srf_var.world_axis_shift.x),
                  Trunc(pts_f3.y+srf_var.world_axis_shift.y),
                  Trunc(pts_l3.x+srf_var.world_axis_shift.x),
                  Trunc(pts_l3.y+srf_var.world_axis_shift.y),
                  PtRct(m1,m2,m3,m4),
                  Unaligned(@LineSME),
                  Nil,
                  Nil
                );
              end;} {$endregion}
            {2.} {$region -fold}
            pts_ptr                    :=Unaligned(@pts                    [0]);
            inner_subgraph_ptr         :=Unaligned(@inner_subgraph_        [0]);
            out_or_inn_subgraph_pts_ptr:=Unaligned(@out_or_inn_subgraph_pts[0]);
            for i:=0 to inner_subgraph__eds_cnt-1 do
              begin
                pts_f3:=(pts_ptr+inner_subgraph_ptr^.first_point)^;
                pts_l3:=(pts_ptr+inner_subgraph_ptr^.last_point )^;
                if ((out_or_inn_subgraph_pts_ptr+inner_subgraph_ptr^.first_point)^=2) then
                  begin
                    pts_f3.x+=n1;
                    pts_f3.y+=n2;
                  end;
                if ((out_or_inn_subgraph_pts_ptr+inner_subgraph_ptr^.last_point )^=2) then
                  begin
                    pts_l3.x+=n1;
                    pts_l3.y+=n2;
                  end;
                ClippedLine1
                (
                  Trunc(pts_f3.x+srf_var.world_axis_shift.x),
                  Trunc(pts_f3.y+srf_var.world_axis_shift.y),
                  Trunc(pts_l3.x+srf_var.world_axis_shift.x),
                  Trunc(pts_l3.y+srf_var.world_axis_shift.y),
                  PtRct(m1,m2,m3,m4),
                  Unaligned(@LineSME),
                  Nil,
                  Nil
                );
              Inc(inner_subgraph_ptr);
            end; {$endregion}
          end; {$endregion}
      (csClippedEdges2 ): {Clipped Edges 2(Slow  )} {$region -fold}
        if (inner_subgraph__eds_cnt>0) then
          begin
            {2 alternative records of the same code block}
            {1.} {$region -fold}
            {for i:=0 to inner_subgraph__eds_cnt-1 do
              begin
                pts_f3:=(pts[inner_subgraph_[i].first_point]);
                pts_l3:=(pts[inner_subgraph_[i].last_point ]);
                if ((out_or_inn_subgraph_pts[inner_subgraph_[i].first_point])=2) then
                  begin
                    pts_f3.x+=n1;
                    pts_f3.y+=n2;
                  end;
                if ((out_or_inn_subgraph_pts[inner_subgraph_[i].last_point ])=2) then
                  begin
                    pts_l3.x+=n1;
                    pts_l3.y+=n2;
                  end;
                ClippedLine2
                (
                  Trunc(pts_f3.x+srf_var.world_axis_shift.x),
                  Trunc(pts_f3.y+srf_var.world_axis_shift.y),
                  Trunc(pts_l3.x+srf_var.world_axis_shift.x),
                  Trunc(pts_l3.y+srf_var.world_axis_shift.y),
                  PtRct(m1,m2,m3,m4),
                  Unaligned(@LineSME),
                  Nil,
                  Nil
                );
              end;} {$endregion}
            {2.} {$region -fold}
            pts_ptr                    :=Unaligned(@pts                    [0]);
            inner_subgraph_ptr         :=Unaligned(@inner_subgraph_        [0]);
            out_or_inn_subgraph_pts_ptr:=Unaligned(@out_or_inn_subgraph_pts[0]);
            for i:=0 to inner_subgraph__eds_cnt-1 do
              begin
                pts_f3:=(pts_ptr+inner_subgraph_ptr^.first_point)^;
                pts_l3:=(pts_ptr+inner_subgraph_ptr^.last_point )^;
                if ((out_or_inn_subgraph_pts_ptr+inner_subgraph_ptr^.first_point)^=2) then
                  begin
                    pts_f3.x+=n1;
                    pts_f3.y+=n2;
                  end;
                if ((out_or_inn_subgraph_pts_ptr+inner_subgraph_ptr^.last_point )^=2) then
                  begin
                    pts_l3.x+=n1;
                    pts_l3.y+=n2;
                  end;
                ClippedLine2
                (
                  Trunc(pts_f3.x+srf_var.world_axis_shift.x),
                  Trunc(pts_f3.y+srf_var.world_axis_shift.y),
                  Trunc(pts_l3.x+srf_var.world_axis_shift.x),
                  Trunc(pts_l3.y+srf_var.world_axis_shift.y),
                  PtRct(m1,m2,m3,m4),
                  Unaligned(@LineSME),
                  Nil,
                  Nil
                );
              Inc(inner_subgraph_ptr);
            end; {$endregion}
          end; {$endregion}
      (csRemoveEdges   ): {Remove Edges---(Fast  )} {$region -fold}
        if (inner_subgraph__eds_cnt>0) then
          begin
            {2 alternative records of the same code block}
            {1.} {$region -fold}
            {for i:=0 to inner_subgraph__eds_cnt-1 do
              begin
                pts_f3:=(pts[inner_subgraph_[i].first_point]);
                pts_l3:=(pts[inner_subgraph_[i].last_point ]);
                if ((out_or_inn_subgraph_pts[inner_subgraph_[i].first_point])=2) then
                  begin
                    pts_f3.x+=n1;
                    pts_f3.y+=n2;
                  end;
                if ((out_or_inn_subgraph_pts[inner_subgraph_[i].last_point ])=2) then
                  begin
                    pts_l3.x+=n1;
                    pts_l3.y+=n2;
                  end;
                if (
                   (pts_f3.x+srf_var.world_axis_shift.x>m1) and
                   (pts_f3.x+srf_var.world_axis_shift.x<m3) and
                   (pts_f3.y+srf_var.world_axis_shift.y>m2) and
                   (pts_f3.y+srf_var.world_axis_shift.y<m4)
                   )
                  then
                    if (
                       (pts_l3.x+srf_var.world_axis_shift.x>m1) and
                       (pts_l3.x+srf_var.world_axis_shift.x<m3) and
                       (pts_l3.y+srf_var.world_axis_shift.y>m2) and
                       (pts_l3.y+srf_var.world_axis_shift.y<m4)
                       )
                      then
                        LineSMN
                        (
                          Trunc(pts_f3.x+srf_var.world_axis_shift.x),
                          Trunc(pts_f3.y+srf_var.world_axis_shift.y),
                          Trunc(pts_l3.x+srf_var.world_axis_shift.x),
                          Trunc(pts_l3.y+srf_var.world_axis_shift.y)
                        );
              end;} {$endregion}
            {2.} {$region -fold}
            pts_ptr                    :=Unaligned(@pts                    [0]);
            inner_subgraph_ptr         :=Unaligned(@inner_subgraph_        [0]);
            out_or_inn_subgraph_pts_ptr:=Unaligned(@out_or_inn_subgraph_pts[0]);
            for i:=0 to inner_subgraph__eds_cnt-1 do
              begin
                pts_f3:=(pts_ptr+inner_subgraph_ptr^.first_point)^;
                pts_l3:=(pts_ptr+inner_subgraph_ptr^.last_point )^;
                if ((out_or_inn_subgraph_pts_ptr+inner_subgraph_ptr^.first_point)^=2) then
                  begin
                    pts_f3.x+=n1;
                    pts_f3.y+=n2;
                  end;
                if ((out_or_inn_subgraph_pts_ptr+inner_subgraph_ptr^.last_point )^=2) then
                  begin
                    pts_l3.x+=n1;
                    pts_l3.y+=n2;
                  end;
                if (
                   (pts_f3.x+srf_var.world_axis_shift.x>m1) and
                   (pts_f3.x+srf_var.world_axis_shift.x<m3) and
                   (pts_f3.y+srf_var.world_axis_shift.y>m2) and
                   (pts_f3.y+srf_var.world_axis_shift.y<m4)
                   )
                  then
                    if (
                       (pts_l3.x+srf_var.world_axis_shift.x>m1) and
                       (pts_l3.x+srf_var.world_axis_shift.x<m3) and
                       (pts_l3.y+srf_var.world_axis_shift.y>m2) and
                       (pts_l3.y+srf_var.world_axis_shift.y<m4)
                       )
                      then
                        LineSMN
                        (
                          Trunc(pts_f3.x+srf_var.world_axis_shift.x),
                          Trunc(pts_f3.y+srf_var.world_axis_shift.y),
                          Trunc(pts_l3.x+srf_var.world_axis_shift.x),
                          Trunc(pts_l3.y+srf_var.world_axis_shift.y)
                        );
              Inc(inner_subgraph_ptr);
            end; {$endregion}
          end; {$endregion}
      (csAdvancedClip  ): {Advanced Clip--(Turbo )} {$region -fold}
        begin
          {n:=CheckDensity1(outer_subgraph_f_ln_var.f_ln_arr0,
                            outer_subgraph_f_ln_var.f_ln_arr2,
                            rect_clp.Width,
                            rect_clp.Height);}
        end; {$endregion}
      (csResilientEdges): {Resilient Edges(Unreal)} {$region -fold}
        if (inner_subgraph__eds_cnt>0) then
          begin
            {2 alternative records of the same code block}
            {1.} {$region -fold}
            {for i:=0 to inner_subgraph__eds_cnt-1 do
              begin
                pts_f3:=(pts[inner_subgraph_[i].first_point]);
                pts_l3:=(pts[inner_subgraph_[i].last_point ]);
                if ((out_or_inn_subgraph_pts[inner_subgraph_[i].first_point])=2) then
                  begin
                    pts_f3.x+=n1;
                    pts_f3.y+=n2;
                  end;
                if ((out_or_inn_subgraph_pts[inner_subgraph_[i].last_point ])=2) then
                  begin
                    pts_l3.x+=n1;
                    pts_l3.y+=n2;
                  end;
                ClippedLine2
                (
                  Trunc(pts_f3.x+srf_var.world_axis_shift.x),
                  Trunc(pts_f3.y+srf_var.world_axis_shift.y),
                  Trunc(pts_l3.x+srf_var.world_axis_shift.x),
                  Trunc(pts_l3.y+srf_var.world_axis_shift.y),
                  rct1
                );
                if not((not IsPtInRct(PtPos(ln_pos.x0,ln_pos.y0),rct1))  and
                       (not IsPtInRct(PtPos(ln_pos.x1,ln_pos.y1),rct1))) then
                  LineR
                  (
                    ln_pos.x0,
                    ln_pos.y0,
                    ln_pos.x1,
                    ln_pos.y1,
                    bmp_dst_ptr,
                    ln_arr_width,
                    color_info,
                    16
                  );
              end;} {$endregion}
            {2.} {$region -fold}
            pts_ptr                    :=Unaligned(@pts                    [0]);
            inner_subgraph_ptr         :=Unaligned(@inner_subgraph_        [0]);
            out_or_inn_subgraph_pts_ptr:=Unaligned(@out_or_inn_subgraph_pts[0]);
            for i:=0 to inner_subgraph__eds_cnt-1 do
              begin
                pts_f3:=(pts_ptr+inner_subgraph_ptr^.first_point)^;
                pts_l3:=(pts_ptr+inner_subgraph_ptr^.last_point )^;
                if ((out_or_inn_subgraph_pts_ptr+inner_subgraph_ptr^.first_point)^=2) then
                  begin
                    pts_f3.x+=n1;
                    pts_f3.y+=n2;
                  end;
                if ((out_or_inn_subgraph_pts_ptr+inner_subgraph_ptr^.last_point )^=2) then
                  begin
                    pts_l3.x+=n1;
                    pts_l3.y+=n2;
                  end;
                ClippedLine2
                (
                  Trunc(pts_f3.x+srf_var.world_axis_shift.x),
                  Trunc(pts_f3.y+srf_var.world_axis_shift.y),
                  Trunc(pts_l3.x+srf_var.world_axis_shift.x),
                  Trunc(pts_l3.y+srf_var.world_axis_shift.y),
                  rct1
                );
                if not((not IsPtInRct(PtPos(ln_pos.x0,ln_pos.y0),rct1))  and
                       (not IsPtInRct(PtPos(ln_pos.x1,ln_pos.y1),rct1))) then
                  LineR
                  (
                    ln_pos.x0,
                    ln_pos.y0,
                    ln_pos.x1,
                    ln_pos.y1,
                    bmp_dst_ptr,
                    ln_arr_width,
                    color_info,
                    16
                  );
              Inc(inner_subgraph_ptr);
            end; {$endregion}
          end; {$endregion}
    end; {$endregion}

  lbl_flood_fill_only:

  {Fill Subgraph Lines-------------} {$region -fold}
  with inner_subgraph_img,local_prop do
    if (clp_stl<>csResilientEdges) then
      begin
        with rct_clp do
          rct2:=PtRct(left+1,top+1,right-1,bottom-1);
        j:=0;
        case eds_bld_stl of
          (dsMonochrome): j:=0;
          (dsAdditive  ): j:=1;
          (dsAlphablend): j:=2;
          (dsInverse   ): j:=3;
          (dsHighlight ): j:=4;
          (dsDarken    ): j:=5;
          (dsGrayscaleR): j:=6;
          (dsGrayscaleG): j:=7;
          (dsGrayscaleB): j:=8;
          (dsMononoise ): j:=9;
        end;
        ArrAdd(ln_arr0,
               ln_arr2,
               rct_clp,
               ln_arr_width,
               ln_arr_height);

        {Fill Edges---------} {$region -fold}
        ArrFillProc[j](ln_arr0,
                       bmp_dst_ptr,
                       ln_arr_width,
                       ln_arr_height,
                       rct_clp,
                       eds_col); {$endregion}

        {Edges Anti-Aliasing} {$region -fold}
        if eds_aa then
          begin
            {ArrClear    (aa_arr1,
                         rct2{srf_var.inn_wnd_rct}{rct_out_ptr^},
                         ln_arr_width);}
            BorderCalc1 (ln_arr0,
                         aa_arr1,
                         ln_arr_width,
                         ln_arr_width,
                         rct2,
                         aa_nz_arr_items_cnt);
            BorderCalc22(ln_arr0,
                         aa_arr1,
                         aa_arr2,
                         ln_arr_width,
                         ln_arr_width,
                         rct2,
                         aa_line_cnt);
            BorderFill ( aa_arr2,
                         0,
                         0,
                         bmp_dst_ptr,
                         ln_arr_width,
                         aa_line_cnt,
                         eds_col,
                         args,
                         PPDec2Proc[pp_dec_2_proc_ind]);
          end; {$endregion}

      end; {$endregion}

end; {$endregion}
procedure TSelPts.SelectdPointsToBmp(x,y:integer; constref pvt:TPtPosF; var pts:TPtPosFArr; constref bmp_dst_ptr:PInteger; constref rct_clp:TPtRect); {$ifdef Linux}[local];{$endif} {$region -fold}
begin
end; {$endregion}
procedure TSelPts.SelPvtAndSplineEdsToBmp;                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  inner_subgraph_edges_ptr      : PEdge;
  i,j,m1,m2,m3,m4               : integer;
  inner_subgraph_edges_count_dec: integer;
begin

  {Misc. Precalc.-----------------------} {$region -fold}
  inner_subgraph_edges_count_dec:=inner_subgraph__eds_cnt-1; {$endregion}

  {Set Drawing Bounds(Inner Window)-----} {$region -fold}
  with srf_var.inn_wnd_rct do
    begin
      m1:=left  +1;
      m2:=top   +1;
      m3:=right -2;
      m4:=bottom-2;
    end; {$endregion}

  {Set Selected Bmp Size----------------} {$region -fold}
  sel_var.sel_bmp.Width :=sel_var.sel_pts_rct.width;
  sel_var.sel_bmp.Height:=sel_var.sel_pts_rct.height; {$endregion}

end; {$endregion}
procedure TSelPts.SelPtsIndsToBmp(var pts:TPtPosFArr);                                                                                                {$ifdef Linux}[local];{$endif} {$region -fold}
begin
end; {$endregion}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.SB_Select_PointsClick                     (sender:TObject);                                                                                                     {$region -fold}
begin
  DrawingPanelsSetVisibility1(down_select_points_ptr,P_Select_Points,P_Draw_Custom_Panel,prev_panel_draw,curr_panel_draw);
  DrawingPanelsSetVisibility2;
end; {$endregion}
procedure TF_MainForm.CB_Select_Points_Selection_ModeSelect     (sender:TObject);                                                                                                     {$region -fold}
begin
  sel_var.ChangeSelectionMode(CB_Select_Points_Selection_Mode.ItemIndex);
end; {$endregion}
procedure TF_MainForm.SB_Outer_Subgraph_Select_ColorClick       (sender:TObject);                                                                                                     {$region -fold}
begin
  CD_Select_Color.Execute;
  with sel_var do
    begin
      IsObjColorAMaskColor;
      with outer_subgraph_img,local_prop do
        begin
          eds_col:=CD_Select_Color.Color;
          if (clp_stl=csResilientEdges) then
            begin
              SetColorInfo(eds_col,color_info);
              FillSelectedBmpAndSelectedPtsBRectDraw;
            end
          else
            begin
              fill_bmp_only:=True;
              FillSelectedBmpAndSelectedPtsBRectDraw;
              fill_bmp_only:=False;
            end;
        end;
    end;
  SB_Outer_Subgraph_Select_Color.Down:=False;
end; {$endregion}
procedure TF_MainForm.CB_Select_Points_Background_StyleSelect   (sender:TObject);                                                                                                     {$region -fold}
begin
  srf_var.bkg_style:=TBackgroundStyle(CB_Select_Points_Background_Style.ItemIndex);
  bkg_pp_calc      :=(CB_Select_Points_Background_Style.ItemIndex in [0..2]) xor (CB_Select_Points_Background_Style.ItemIndex=3);
end; {$endregion}
procedure TF_MainForm.CB_Select_Points_Line_StyleSelect         (sender:TObject);                                                                                                     {$region -fold}
begin
  with sel_var,outer_subgraph_img,local_prop do
    begin
      with args do
        begin
          alpha:=032;
          pow  :=032;
          d    :=032;
        end;
      case CB_Select_Points_Line_Style.ItemIndex of
        0:
          begin
            eds_bld_stl:=dsMonochrome;
            args.alpha :=064;
          end;
        1: eds_bld_stl :=dsAdditive;
        2:
          begin
            eds_bld_stl:=dsAlphaBlend;
            args.alpha :=127{64};
          end;
        3: eds_bld_stl :=dsInverse;
        4:
          begin
            eds_bld_stl:=dsHighlight;
            args.pow   :=064;
          end;
        5:
          begin
            eds_bld_stl:=dsDarken;
            args.pow   :=064;
          end;
        6:
          begin
            eds_bld_stl:=dsGrayscaleR;
            args.d     :=064;
          end;
        7:
          begin
            eds_bld_stl:=dsGrayscaleG;
            args.d     :=064;
          end;
        8:
          begin
            eds_bld_stl:=dsGrayscaleB;
            args.d     :=064;
          end;
        9: eds_bld_stl :=dsMononoise;
      end;
      pp_dec_2_proc_ind:=GetEnumVal(eds_bld_stl);
      if (eds_bld_stl=dsMonochrome) then
        pp_dec_2_proc_ind:=2;
      fill_bmp_only:=True;
      FillSelectedBmpAndSelectedPtsBRectDraw;
      fill_bmp_only:=False;
    end;
end; {$endregion}
procedure TF_MainForm.CB_Select_Points_Clip_StyleSelect         (sender:TObject);                                                                                                     {$region -fold}
begin
  L_Select_Points_Relative_Bucket_Size.Visible:=False;
  SE_Select_Points_Bucket_Size.Visible        :=False;
  L_Select_Points_Bucket_Size_Value.Visible   :=False;
  with sel_var,outer_subgraph_img,local_prop do
    case CB_Select_Points_Clip_Style.ItemIndex of
      0: clp_stl:=csClippedEdges1;
      1: clp_stl:=csClippedEdges2;
      2: clp_stl:=csRemoveEdges;
      3:
        begin
          clp_stl                                     :=csAdvancedClip;
          L_Select_Points_Relative_Bucket_Size.Visible:=True;
          SE_Select_Points_Bucket_Size.Visible        :=True;
          L_Select_Points_Bucket_Size_Value.Visible   :=True;
        end;
      4:
        begin
          clp_stl:=csResilientEdges;
          SetColorInfo(eds_col,color_info);
        end;
    end;
  FillSelectedBmpAndSelectedPtsBRectDraw;
end; {$endregion}
procedure TF_MainForm.SE_Select_Points_Bucket_SizeChange        (sender:TObject);                                                                                                     {$region -fold}
begin
  if show_spline then
    if (sel_var.sel_pts_cnt>0) then
      begin
        bucket_size_change:=True;
        BucketSizeChange(SE_Select_Points_Bucket_Size.Value);
        bucket_size_change:=False;
      end;
end; {$endregion}
procedure TF_MainForm.SB_Inner_Subgraph_Select_ColorClick       (sender:TObject);                                                                                                     {$region -fold}
begin
  CD_Select_Color.Execute;
  sel_var.inner_subgraph_img.local_prop.eds_col:=CD_Select_Color.Color;
  IsObjColorAMaskColor;
  {Fill Selected Bmp}
  if exp0 then
    begin
        with sel_var do
          begin
            {Fill Selected Bmp(Inner Subgraph)}
            {TODO}
            {Fill Selected Bmp(Selected Points)}
            {TODO}
          end;
      InvalidateInnerWindow;
    end;
  SB_Inner_Subgraph_Select_Color.Down:=False;
end; {$endregion}
procedure TF_MainForm.SB_Selected_Points_Select_ColorClick      (sender:TObject);                                                                                                     {$region -fold}
begin
  CD_Select_Color.Execute;
  sel_var.sel_pts_big_img.local_prop.eds_col:=CD_Select_Color.Color;
  IsObjColorAMaskColor;
  {Fill Selected Bmp}
  if exp0 then
    begin
        with sel_var do
          begin
            {Fill Selected Bmp(Inner Subgraph)}
            {TODO}
            {Fill Selected Bmp(Selected Points)}
            {TODO}
        end;
      InvalidateInnerWindow;
    end;
  SB_Selected_Points_Select_Color.Down:=False;
end; {$endregion}
procedure TF_MainForm.CB_Select_Points_Show_Selected_EdgesChange(sender:TObject);                                                                                                     {$region -fold}
var
  pvt_shift: TPtPosF;
begin
  with srf_var,sel_var,pvt_var do
    begin
         draw_out_subgraph:=CB_Select_Points_Show_Selected_Edges.Checked;
      if draw_out_subgraph then
        pvt_draw_sel_eds_on :=pvt
      else
        pvt_draw_sel_eds_off:=pvt;
      pvt_shift.x:=pvt_draw_sel_eds_on.x-pvt_draw_sel_eds_off.x;
      pvt_shift.y:=pvt_draw_sel_eds_on.y-pvt_draw_sel_eds_off.y;
      if exp0 then
        begin
          if draw_out_subgraph then
            begin
              if (pvt_draw_sel_eds_off<>pvt_draw_sel_eds_on)  then
                begin
                  OuterSubgraphToBmp(Trunc(pvt.x)+Trunc(pvt_shift.x),
                                     Trunc(pvt.y)+Trunc(pvt_shift.y),
                                     pvt_var.pvt,
                                     sln_var.sln_pts,
                                     srf_var.srf_bmp_ptr,
                                     srf_var.inn_wnd_rct);
                  InvalidateInnerWindow;
                end
              else
                begin
                  fill_bmp_only:=True;
                  FillSelectedBmpAndSelectedPtsBRectDraw;
                  fill_bmp_only:=False;
                end;
            end
          else
            begin
              LowerBmpToMainBmp;
              if show_selected_pts_b_rect then
                SelectedPtsRectDraw(srf_bmp.Canvas,sel_pts_rct,clPurple,clNavy);
              InvalidateInnerWindow;
            end;
        end;
    end;
end; {$endregion}
procedure TF_MainForm.CB_Select_Points_Show_BoundsChange        (sender:TObject);                                                                                                     {$region -fold}
begin
  show_selected_pts_b_rect:=CB_Select_Points_Show_Bounds.Checked;
  if exp0 then
    FillSelectedBmpAndSelectedPtsBRectDraw;
end; {$endregion}
{$endregion}

// (World Axis ) Мировая ось:
{LI} {$region -fold}
procedure WorldAxisCreate;                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  // Create World Axis Icon:
  with srf_var do
    world_axis_bmp:=TFastImage.Create(srf_bmp_ptr,
                                      srf_bmp.width,
                                      srf_bmp.height,
                                      inn_wnd_rct,
                                      max_sprite_w_h_rct,
                                      Application.Location+WORLD_AXIS_ICON,
                                      @F_MainForm.IL_World_Axis.GetBitmap,
                                      0);
  with srf_var.world_axis_bmp do
    begin
      SetPPInfo (clRed);
      SetGradVec(0,0,0,100);

      col_trans_arr[01]:=132;
      col_trans_arr[02]:=132;
      col_trans_arr[03]:=132;
      col_trans_arr[04]:=132;
      col_trans_arr[05]:=132;
      col_trans_arr[06]:=132;
      col_trans_arr[07]:=132;
      col_trans_arr[08]:=132;
      col_trans_arr[09]:=132;
      col_trans_arr[10]:=0;
      col_trans_arr[11]:=255;
      col_trans_arr[12]:=0;
      col_trans_arr[13]:=255;
      col_trans_arr[14]:=0;
      col_trans_arr[15]:=255;
      col_trans_arr[16]:=0;

      pix_drw_type             :=00{01}; //must be in range of [0..002]

      fx_cnt                   :=00{01}; //must be in range of [0..255]

      fx_arr[0].rep_cnt        :=01; //must be in range of [0..255]

      fx_arr[0].nt_pix_srf_type:=01; //must be in range of [0..001]
      fx_arr[0].nt_pix_cfx_type:=17; //must be in range of [0..255]
      fx_arr[0].nt_pix_cng_type:=00; //must be in range of [0..001]

      fx_arr[0].pt_pix_srf_type:=01; //must be in range of [0..001]
      fx_arr[0].pt_pix_cfx_type:=17; //must be in range of [0..255]
      fx_arr[0].pt_pix_cng_type:=00; //must be in range of [0..001]

    end;
end; {$endregion}
procedure WorldAxisBmp(constref x,y:integer); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  {bmp_dst:Graphics.TBitmap
  bmp_dst.BeginUpdate(True);
  with bmp_dst.Canvas,pvt do
    begin
      Pen.Mode:=pmNotMask{pmNotXor}{pmCopy};

      Pen.Color:=clGreen;

      Line  (Trunc(00+x),Trunc(y+00),
             Trunc(60+x),Trunc(y+00));
      LineTo(Trunc(50+x),Trunc(y-02));
      LineTo(Trunc(50+x),Trunc(y+02));
      LineTo(Trunc(60+x),Trunc(y+00));

      Line  (Trunc( 00+x),Trunc(y+00),
             Trunc( 00+x),Trunc(y-60));
      LineTo(Trunc(-02+x),Trunc(y-50));
      LineTo(Trunc( 02+x),Trunc(y-50));
      LineTo(Trunc( 00+x),Trunc(y-60));

      Pen.Color:=clBlue;

      Pen.Style:=psDot;
      Line  (Trunc( 00+x),Trunc(y+00),
             Trunc(-60+x),Trunc(y+00));
      Pen.Style:=psSolid;
      LineTo(Trunc(-50+x),Trunc(y-02));
      LineTo(Trunc(-50+x),Trunc(y+02));
      LineTo(Trunc(-60+x),Trunc(y+00));

      Pen.Style:=psDot;
      Line  (Trunc( 00+x),Trunc(y+00),
             Trunc( 00+x),Trunc(y+60));
      Pen.Style:=psSolid;
      LineTo(Trunc(-02+x),Trunc(y+50));
      LineTo(Trunc( 02+x),Trunc(y+50));
      LineTo(Trunc( 00+x),Trunc(y+60));
    end;
  bmp_dst.EndUpdate(False);}

  with srf_var,world_axis_bmp do
    begin
      SetRctPos(x+srf_var.world_axis_shift.x,
                y+srf_var.world_axis_shift.y);
      SdrProc[3];
    end;
end; {$endregion}
{$endregion}

// (Local Pivot) Локальная ось:
{LI} {$region -fold}
constructor TPivot.Create(w,h:TColor);                                                                             {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  pvt_draw_sel_eds_off.x:=1.0;
  move_pvt_to_pt_button:=True;

  {Create Out-of-Window-Marker--} {$region -fold}
  {pvt_marker_bmp:=TPortableNetworkGraphic.Create;
  pvt_marker_bmp.LoadFromFile(Application.Location+'Brashes\'+'PivotMarkerMasked3.png');
  for i:=0 to 3 do
    begin
      pvt_marker_arr[i]:=Graphics.TBitmap.Create;
      pvt_marker_arr[i].Width :=w;
      pvt_marker_arr[i].Height:=h;
      pvt_marker_arr[i].PixelFormat:=pf32bit;
    end;
  pvt_marker_arr[0].Canvas.CopyRect(Rect(0,0,w,h),pvt_marker_bmp.Canvas,Rect(0,0,w,h));
  pvt_marker_arr[1].Canvas.CopyRect(Rect(0,0,w,h),pvt_marker_bmp.Canvas,Rect(w,0,2*w,h));
  pvt_marker_arr[2].Canvas.CopyRect(Rect(0,0,w,h),pvt_marker_bmp.Canvas,Rect(w,h,2*w,2*h));
  pvt_marker_arr[3].Canvas.CopyRect(Rect(0,0,w,h),pvt_marker_bmp.Canvas,Rect(0,h,w,2*h));} {$endregion}

  {Create Pivot Icon------------} {$region -fold}
  pvt_bmp:=Graphics.TBitmap.Create;
  F_MainForm.IL_Pivot_Bmp.GetBitmap(0,pvt_bmp); {$endregion}

  {Create Selection Tools Marker} {$region -fold}
  SelectionToolsMarkerCreate; {$endregion}

  // pvt_bmp.Free;
end; {$endregion}
destructor  TPivot.Destroy;                                                                                        {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  inherited Destroy;
end; {$endregion}
procedure TPivot.SelectionToolsMarkerCreate;                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  sel_tls_mrk:=TFastImage.Create(srf_var.srf_bmp_ptr,
                                 srf_var.srf_bmp.width,
                                 srf_var.srf_bmp.height,
                                 srf_var.inn_wnd_rct,
                                 max_sprite_w_h_rct,
                                 Application.Location+SELECTION_TOOLS_MARKER,
                                 @F_MainForm.IL_Select_Points.GetBitmap,
                                 0);
  // Drawing Settings:
  with sel_tls_mrk do
    begin
      col_trans_arr[02]:=100;
      pix_drw_type     :=0; //must be in range of [0..002]
      nt_pix_srf_type  :=1; //must be in range of [0..002]
      nt_pix_cfx_type  :=2; //must be in range of [0..002]
      nt_pix_cng_type  :=1; //must be in range of [0..001]
      pt_pix_srf_type  :=1; //must be in range of [0..002]
      pt_pix_cfx_type  :=2; //must be in range of [0..002]
      pt_pix_cng_type  :=1; //must be in range of [0..001]
      fx_cnt           :=0; //must be in range of [0..255]
    end;
end; {$endregion}
procedure TPivot.SelectionToolsMarkerDraw(constref x,y:integer);                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with sel_tls_mrk do
    begin
      SetRctPos(x,y);
      SdrProc[3];
    end;
end; {$endregion}
procedure TPivot.SetPivotAxisRect(constref pt_rct:TPtRect; constref margin:TColor=10);                     inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  pvt_axis_rect:=PtRct(pt_rct.left  +margin,
                       pt_rct.top   +margin,
                       pt_rct.right -margin,
                       pt_rct.bottom-margin);
end; {$endregion}
procedure TPivot.PivotCalc(constref pts:TPtPosFArr; constref sel_pts_inds:TColorArr; constref sel_pts_cnt:TColor); {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sel_pts_inds_ptr: PInteger;
  p               : TPtPosF;
  i               : integer;
begin
  p  :=Default(TPtPosF);
  pvt:=Default(TPtPosF);
  sel_pts_inds_ptr:=Unaligned(@sel_pts_inds[0]);
  for i:=0 to sel_pts_cnt-1 do
    begin
      p.x+=pts[sel_pts_inds_ptr^].x;
      p.y+=pts[sel_pts_inds_ptr^].y;
      Inc(sel_pts_inds_ptr);
    end;
  pvt.x:=p.x/sel_pts_cnt+srf_var.world_axis_shift.x;
  pvt.y:=p.y/sel_pts_cnt+srf_var.world_axis_shift.y;
  pvt_origin:=pvt;
end; {$endregion}
procedure TPivot.AlignPivotOnX         (var x,y:integer; shift:TShiftState);                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  if need_align_pivot_x then
    y:=align_pivot.y;
  if (shift=[ssCtrl]) then
    begin
      need_align_pivot_y:=False;
      if (not need_align_pivot_x) then
        align_pivot.y:=y;
      need_align_pivot_x:=True;
    end
  else
    need_align_pivot_x:=False;
end; {$endregion}
procedure TPivot.AlignPivotOnY         (var x,y:integer; shift:TShiftState);                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  if need_align_pivot_y then
    x:=align_pivot.x;
  if (shift=[ssShift]) then
    begin
      need_align_pivot_x:=False;
      if (not need_align_pivot_y) then
        align_pivot.x:=x;
      need_align_pivot_y:=True;
    end
  else
    need_align_pivot_y:=False;
end; {$endregion}
procedure TPivot.AlignPivotOnP         (var x,y:integer; shift:TShiftState);                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  if (shift=[ssAlt]) then
    with srf_var,sln_var,crc_sel_var do
      PivotToPoint(x,y,dup_pts_arr,inn_wnd_rct,srf_bmp.width,crc_rad);
end; {$endregion}
procedure TPivot.PivotToPoint              (x,y:integer; constref pts:TPtPosFArr; constref pts_cnt:TColor;                                  constref crc_rad_sqr:TColor);                  {$ifdef Linux}[local];{$endif} {$region -fold}
var
  pts_ptr               : PPtPosF;
  is_point_in_circle_ptr: PByteBool;
  v,inf,sup             : double;
  i,ind_of_min          : integer;
  draw                  : boolean;
begin

  inf                   :=0;
  sup                   :=crc_rad_sqr;
  ind_of_min            :=0;

  pts_ptr               :=Unaligned(@pts                       [0]);
  is_point_in_circle_ptr:=Unaligned(@sel_var.is_point_in_circle[0]);
  for i:=0 to pts_cnt-1 do
    begin
      v:=(pts_ptr^.x-x)*(pts_ptr^.x-x)+
         (pts_ptr^.y-y)*(pts_ptr^.y-y);
      Inc(pts_ptr);
      if (v<=crc_rad_sqr) then
        begin
          if (not is_point_in_circle_ptr^) then
            begin
              is_point_in_circle_ptr^:=True;
              if (v<=sup-inf) then
                begin
                  inf       :=sup-v;
                  ind_of_min:=i;
                end;
            end;
          if is_point_in_circle_ptr^ then
            is_point_in_circle_ptr^:=False;
        end;
      Inc(is_point_in_circle_ptr);
    end;

  draw:=(pts[ind_of_min].x-x)*(pts[ind_of_min].x-x)+
        (pts[ind_of_min].y-y)*(pts[ind_of_min].y-y)<=crc_rad_sqr;

  if draw then
    begin
      pvt.x:=pts[ind_of_min].x;
      pvt.y:=pts[ind_of_min].y;
    end
  else
    begin
      pvt.x:=x;
      pvt.y:=y;
    end;
  pvt_to_pt_draw_pt:=draw;

end; {$endregion}
procedure TPivot.PivotToPoint              (x,y:integer; constref pts:TPtPos2Arr; constref rct_clp:TPtRect; constref arr_dst_width:TColor; constref crc_rad    :TColor; density:TColor=1); {$ifdef Linux}[local];{$endif} {$region -fold}
var
  a,b,b2,c,m: double;
  i,d       : integer;
  draw      : boolean;
begin

  {
    TLnPos=packed record
      x0,y0,x1,y1: integer;
    end;

    TPtPos=packed record
      x,y: integer;
    end;

    srf_var           - target drawing object;
    srf_bmp           - target drawing surface(bitmap);
    srf_bmp_ptr       - pointer to target drawing surface(srf_bmp);
    rct_clp           - target drawing rectangular area;
    crc_rad           - circle radius;
    arr_dst_width     - width of destination buffer;
    mos_mot_vec       - mouse motion vector;
    mos_mot_vec       : TLnPos;
    pvt_prev          - previous pivot;
    pvt_prev          : TPtPos;
    pvt               - pivot;
    pvt               : TPtPos;
    pvt_to_pt_draw_pt - checks if pivot needs to be drawn;
  }

  draw   :=False;
  density:=Min(density,crc_rad); // density between circles;

  mos_mot_vec.x1:=x;
  mos_mot_vec.y1:=y;

  for i:=1 to Trunc(crc_rad/density) do
    begin
      d:=density*i;
      if IsPtInRct(x,y,PtRct(rct_clp.left  +d,
                             rct_clp.top   +d,
                             rct_clp.right -d,
                             rct_clp.bottom-d)) then
        begin
          if CircleW(x,y,d,pts,arr_dst_width,pvt) then // drawing of regular circle(wave)
            begin
              draw:=True;
              Break;
            end;
        end
      else
        begin
          if CircleWC(x,y,d,pts,rct_clp,arr_dst_width,pvt) then // drawing of clipped circle(wave)
            begin
              draw:=True;
              Break;
            end;
        end;
    end;

  if draw then
    begin
      //4*(m^2):=2*(b^2+c^2)-a^2;
      m :=  sqrt(sqr(mos_mot_vec.x0-mos_mot_vec.x1)+sqr(mos_mot_vec.y0-mos_mot_vec.y1));
      a :=2*sqrt(sqr(pvt_prev.x    -pvt.x)         +sqr(pvt_prev.y    -pvt.y));
      b :=  sqrt(sqr(mos_mot_vec.x1-pvt.x)         +sqr(mos_mot_vec.y1-pvt.y));
      b2:=  sqrt(sqr(pvt.x+pvt_prev.x-mos_mot_vec.x0-mos_mot_vec.x1)+
                 sqr(pvt.y+pvt_prev.y-mos_mot_vec.y0-mos_mot_vec.y1));
      c :=  sqrt(((4*m*m+a*a)/2)-b*b);
      if (Trunc(b2)=Max(Trunc(b),Trunc(c))) then
        begin
          pvt.x:=pvt_prev.x;
          pvt.y:=pvt_prev.y;
        end;
      pvt_prev.x:=Trunc(pvt.x);
      pvt_prev.y:=Trunc(pvt.y);
    end
  else
    begin
      pvt.x:=x;
      pvt.y:=y;
    end;
  pvt_to_pt_draw_pt:=draw;

  with sel_var,crc_sel_var,crc_sel_rct do
    begin
      FilSelPtsObj(x-crc_rad,y-crc_rad);
      {if IsPtInRct(x,y,PtRct(rct_clp.left  +crc_rad,
                              rct_clp.top   +crc_rad,
                              rct_clp.right -crc_rad,
                              rct_clp.bottom-crc_rad)) then
        Circle (x,y,crc_rad,srf_var.srf_bmp_ptr,                    srf_var.srf_bmp.width,clBlue)
      else
        CircleC(x,y,crc_rad,srf_var.srf_bmp_ptr,srf_var.inn_wnd_rct,srf_var.srf_bmp.width,clBlue);}
    end;

  mos_mot_vec.x0:=mos_mot_vec.x1;
  mos_mot_vec.y0:=mos_mot_vec.y1;

end; {$endregion}
procedure TPivot.SelectedPtsBmpPositionCalc(x,y:integer; var sel_pts_rect:TRect);                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with sel_pts_rect do
    begin
      Left  +=x-Trunc(pvt.x);
      Top   +=y-Trunc(pvt.y);
      Right +=x-Trunc(pvt.x);
      Bottom+=y-Trunc(pvt.y);
    end;
end; {$endregion}
procedure TPivot.SelectedPtsScalingCalc    (x,y:integer; var pts:TEdgeArr);                                        {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure TPivot.SelectedPtsRotationCalc   (x,y:integer; var pts:TEdgeArr);                                        {$ifdef Linux}[local];{$endif} {$region -fold}
begin
end; {$endregion}
procedure TPivot.IsPivotOutOfInnerWindow(var custom_rect:TPtRect; constref pvt_:TPtPosF);                  inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  m1,m2,m3,m4: integer;
  x0,y0,x1,y1: integer;
  k,b,d:       integer;
begin

  begin
    pvt_marker_draw  :=False;
    pvt_marker_left  :=False;
    pvt_marker_top   :=False;
    pvt_marker_right :=False;
    pvt_marker_bottom:=False;
  end;

  with srf_var do
    begin
      m1:=custom_rect.Left;
      m2:=custom_rect.Top;
      m3:=custom_rect.Right;
      m4:=custom_rect.Bottom;
    end;

  x0:=Trunc((m1+m3)/2);
  y0:=Trunc((m2+m4)/2);
  x1:=Trunc(pvt.x);
  y1:=Trunc(pvt.y);

  k:=y1-y0;
  b:=y0*x1-y1*x0;
  d:=x1-x0;

  {Сверху-слева}
  if (pvt.x<m1) and
     (pvt.y<m2) then
    begin
      if ((k*m1+b)/d>m2) then
        begin
          pvt_marker_draw:=True;
          pvt_marker_left:=True;
          pvt_marker.x:=m1;
          pvt_marker.y:=(k*m1+b) div d;
        end
      else
        begin
          pvt_marker_draw:=True;
          pvt_marker_top :=True;
          pvt_marker.x:=(d*m2-b) div k;
          pvt_marker.y:=m2;
        end;
      Exit;
    end

  {Сверху}
  else
  if (pvt.x>m1) and
     (pvt.x<m3) and
     (pvt.y<m2) then
    begin
      pvt_marker_draw:=True;
      pvt_marker_top :=True;
      pvt_marker.x:=(d*m2-b) div k;
      pvt_marker.y:=m2;
      Exit;
    end

  {Сверху-справа}
  else
  if (pvt.x>m3) and
     (pvt.y<m2) then
    begin
      if ((k*m3+b)/d>m2) then
        begin
          pvt_marker_draw :=True;
          pvt_marker_right:=True;
          pvt_marker.x:=m3;
          pvt_marker.y:=(k*m3+b) div d;
        end
      else
        begin
          pvt_marker_draw:=True;
          pvt_marker_top :=True;
          pvt_marker.x:=(d*m2-b) div k;
          pvt_marker.y:=m2;
        end;
      Exit;
    end

  {Слева}
  else
  if (pvt.y>m2) and
     (pvt.y<m4) and
     (pvt.x<m1) then
    begin
      pvt_marker_draw:=True;
      pvt_marker_left:=True;
      pvt_marker.x:=m1;
      pvt_marker.y:=(k*m1+b) div d;
      Exit;
    end

  {Справа}
  else
  if (pvt.y>m2) and
     (pvt.y<m4) and
     (pvt.x>m3) then
    begin
      pvt_marker_draw :=True;
      pvt_marker_right:=True;
      pvt_marker.x:=m3;
      pvt_marker.y:=(k*m3+b) div d;
      Exit;
    end

  {Снизу-слева}
  else
  if (pvt.x<m1) and
     (pvt.y>m4) then
    begin
      if ((k*m1+b)/d<m4) then
        begin
          pvt_marker_draw:=True;
          pvt_marker_left:=True;
          pvt_marker.x:=m1;
          pvt_marker.y:=(k*m1+b) div d;
        end
      else
        begin
          pvt_marker_draw  :=True;
          pvt_marker_bottom:=True;
          pvt_marker.x:=(d*m4-b) div k;
          pvt_marker.y:=m4;
        end;
      Exit;
    end

  {Снизу}
  else
  if (pvt.x>m1) and
     (pvt.x<m3) and
     (pvt.y>m4) then
    begin
      pvt_marker_draw  :=True;
      pvt_marker_bottom:=True;
      pvt_marker.x:=(d*m4-b) div k;
      pvt_marker.y:=m4;
      Exit;
    end

  {Снизу-справа}
  else
  if (pvt.x>m3) and
     (pvt.y>m4) then
    begin
      if ((k*m3+b)/d<m4) then
        begin
          pvt_marker_draw:=True;
          pvt_marker_right:=True;
          pvt_marker.x:=m3;
          pvt_marker.y:=(k*m3+b) div d;
        end
      else
        begin
          pvt_marker_draw  :=True;
          pvt_marker_bottom:=True;
          pvt_marker.x:=(d*m4-b) div k;
          pvt_marker.y:=m4;
        end;
      Exit;
    end

  else
    pvt_marker_draw:=False;

end; {$endregion}
procedure TPivot.PivotMarkerDraw (cnv_dst:TCanvas);                                                        inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  cnv_dst.Rectangle(pvt_marker.x-10,
                    pvt_marker.y-10,
                    pvt_marker.x+11,
                    pvt_marker.y+11);
  {if pvt_marker_left then
    begin
      cnv_dst.Draw(pvt_marker.x-8,
                   pvt_marker.y-8,
                   pvt_marker_arr[0]);
      Exit;
    end;
  if pvt_marker_top then
    begin
      cnv_dst.Draw(pvt_marker.x-8,
                   pvt_marker.y-8,
                   pvt_marker_arr[1]);
      Exit;
    end;
  if pvt_marker_right then
    begin
      cnv_dst.Draw(pvt_marker.x-17,
                   pvt_marker.y-17,
                   pvt_marker_arr[2]);
      Exit;
    end;
  if pvt_marker_bottom then
    begin
      cnv_dst.Draw(pvt_marker.x-17,
                   pvt_marker.y-17,
                   pvt_marker_arr[3]);
      Exit;
    end;}
end; {$endregion}
procedure TPivot.PivotToPointDraw(cnv_dst:TCanvas);                                                        inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with cnv_dst do
    begin
      Pen.Mode   :=pmcopy;
      Pen.Color  :=clRed;
      Brush.Style:=bsClear;
      Rectangle(Trunc(pvt.x)-4,
                Trunc(pvt.y)-4,
                Trunc(pvt.x)+5,
                Trunc(pvt.y)+5);
    end;
end; {$endregion}
procedure TPivot.PivotAxisDraw   (cnv_dst:TCanvas; constref custom_rct:TPtRect; constref shift:TPtPos);    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with cnv_dst do
    begin

      Pen.Width:=3;

      Pen.Mode :=pmMerge;
      Pen.Color:=clGreen;
      Pen.Style:=psSolid;
      {$ifdef Windows}
      MoveTo(custom_rct.left ,Trunc(pvt.y+shift.y));
      Windows.LineTo(Handle  ,Trunc(pvt.x+shift.x)-10,
                              Trunc(pvt.y+shift.y));
      MoveTo(custom_rct.right,Trunc(pvt.y+shift.y));
      Windows.LineTo(Handle  ,Trunc(pvt.x+shift.x)+10,
                              Trunc(pvt.y+shift.y));
      MoveTo(                 Trunc(pvt.x+shift.x),custom_rct.top   );
      Windows.LineTo(Handle  ,Trunc(pvt.x+shift.x),
                              Trunc(pvt.y+shift.y)-10);
      MoveTo(                 Trunc(pvt.x+shift.x),custom_rct.bottom);
      Windows.LineTo(Handle  ,Trunc(pvt.x+shift.x),
                              Trunc(pvt.y+shift.y)+10);
      {$else}
      Line(custom_rct.left ,Trunc(pvt.y+shift.y),
                            Trunc(pvt.x+shift.x)-10,
                            Trunc(pvt.y+shift.y));
      Line(custom_rct.right,Trunc(pvt.y+shift.y),
                            Trunc(pvt.x+shift.x)+10,
                            Trunc(pvt.y+shift.y));
      Line(                 Trunc(pvt.x+shift.x),custom_rect.top   ,
                            Trunc(pvt.x+shift.x),
                            Trunc(pvt.y+shift.y)-10);
      Line(                 Trunc(pvt.x+shift.x),custom_rect.bottom,
                            Trunc(pvt.x+shift.x),
                            Trunc(pvt.y+shift.y)+10);
      {$endif}

      Pen.Mode :=pmCopy;
      Pen.Color:=clLime;
      Pen.Style:=psDash;
      {$ifdef Windows}
      MoveTo(custom_rct.left ,Trunc(pvt.y+shift.y));
      Windows.LineTo(Handle  ,Trunc(pvt.x+shift.x)-10,
                              Trunc(pvt.y+shift.y));
      MoveTo(custom_rct.right,Trunc(pvt.y+shift.y));
      Windows.LineTo(Handle  ,Trunc(pvt.x+shift.x)+10,
                              Trunc(pvt.y+shift.y));
      MoveTo(                 Trunc(pvt.x+shift.x),custom_rct.top   );
      Windows.LineTo(Handle  ,Trunc(pvt.x+shift.x),
                              Trunc(pvt.y+shift.y)-10);
      MoveTo(                 Trunc(pvt.x+shift.x),custom_rct.bottom);
      Windows.LineTo(Handle  ,Trunc(pvt.x+shift.x),
                              Trunc(pvt.y+shift.y)+10);
      {$else}
      Line(custom_rct.left ,Trunc(pvt.y+shift.y),
                            Trunc(pvt.x+shift.x)-10,
                            Trunc(pvt.y+shift.y));
      Line(custom_rct.right,Trunc(pvt.y+shift.y),
                            Trunc(pvt.x+shift.x)+10,
                            Trunc(pvt.y+shift.y));
      Line(                 Trunc(pvt.x+shift.x),custom_rct.top   ,
                            Trunc(pvt.x+shift.x),
                            Trunc(pvt.y+shift.y)-10);
      Line(                 Trunc(pvt.x+shift.x),custom_rct.bottom,
                            Trunc(pvt.x+shift.x),
                            Trunc(pvt.y+shift.y)+10);
      {$endif}

      Pen.Width:=1;
      Pen.Mode :=pmCopy;
      Pen.Style:=psSolid;

    end;
end; {$endregion}
procedure TPivot.PivotBoundsDraw;                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  //
end; {$endregion}
procedure TPivot.PivotAngleDraw;                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  //
end; {$endregion}
procedure TPivot.PivotModeDraw   (cnv_dst:TCanvas);                                                        inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with cnv_dst do
    case pvt_mode of
      (pmPivotMove):
        begin
          Pen.Mode :=pmCopy;
          Pen.Color:=clRed;
          Line     (Trunc(pvt.x),   Trunc(pvt.y)-18,
                    Trunc(pvt.x)+18,Trunc(pvt.y));
          Pen.Width:=2;
          Line     (Trunc(pvt.x),   Trunc(pvt.y)-24,
                    Trunc(pvt.x)+24,Trunc(pvt.y));
          {
          Pen.Color:=clGreen;
          Line     (Trunc(pvt.x),   Trunc(pvt.y),
                    Trunc(pvt.x)+60,Trunc(pvt.y));
          LineTo   (Trunc(pvt.x)+50,Trunc(pvt.y)-2);
          LineTo   (Trunc(pvt.x)+50,Trunc(pvt.y)+2);
          LineTo   (Trunc(pvt.x)+60,Trunc(pvt.y));
          Pen.Color:=clBlue;
          Line     (Trunc(pvt.x),   Trunc(pvt.y),
                    Trunc(pvt.x),   Trunc(pvt.y)-60);
          LineTo   (Trunc(pvt.x)-2, Trunc(pvt.y)-50);
          LineTo   (Trunc(pvt.x)+2, Trunc(pvt.y)-50);
          LineTo   (Trunc(pvt.x),   Trunc(pvt.y)-60);
          }
          Pen.Width:=1;
        end;
      (pmPivotScale):
        begin
          Pen.Mode :=pmCopy;
          Pen.Color:=clRed;
          Line     (Trunc(pvt.x),   Trunc(pvt.y)-18,
                    Trunc(pvt.x)+18,Trunc(pvt.y)-18);
          Line     (Trunc(pvt.x)+18,Trunc(pvt.y)-18,
                    Trunc(pvt.x)+18,Trunc(pvt.y));
          Pen.Width:=2;
          Line     (Trunc(pvt.x),   Trunc(pvt.y)-24,
                    Trunc(pvt.x)+24,Trunc(pvt.y)-24);
          Line     (Trunc(pvt.x)+24,Trunc(pvt.y)-24,
                    Trunc(pvt.x)+24,Trunc(pvt.y));
          {
          Pen.Color:=clGreen;
          Line     (Trunc(pvt.x),   Trunc(pvt.y),
                    Trunc(pvt.x)+60,Trunc(pvt.y));
          LineTo   (Trunc(pvt.x)+50,Trunc(pvt.y)-2);
          LineTo   (Trunc(pvt.x)+50,Trunc(pvt.y)+2);
          LineTo   (Trunc(pvt.x)+60,Trunc(pvt.y));
          Pen.Color:=clBlue;
          Line     (Trunc(pvt.x),   Trunc(pvt.y),
                    Trunc(pvt.x),   Trunc(pvt.y)-60);
          LineTo   (Trunc(pvt.x)-2, Trunc(pvt.y)-50);
          LineTo   (Trunc(pvt.x)+2, Trunc(pvt.y)-50);
          LineTo   (Trunc(pvt.x),   Trunc(pvt.y)-60);
          }
          Pen.Width:=1;
        end;
      (pmPivotRotate):
        begin
          Brush.Style:=bsClear;
          Pen.Mode   :=pmCopy;
          Pen.Color  :=clRed;
          Pen.Width  :=2;
          RadialPie(Trunc(pvt.x)-24,Trunc(pvt.y)+24,
                    Trunc(pvt.x)+24,Trunc(pvt.y)-24,3,-1440);
          Pen.Width  :=1;
          RadialPie(Trunc(pvt.x)-18,Trunc(pvt.y)+18,
                    Trunc(pvt.x)+18,Trunc(pvt.y)-18,3,-1440);
          {
          Pen.Color:=clGreen;
          Line     (Trunc(pvt.x),   Trunc(pvt.y),
                    Trunc(pvt.x)+60,Trunc(pvt.y));
          LineTo   (Trunc(pvt.x)+50,Trunc(pvt.y)-2);
          LineTo   (Trunc(pvt.x)+50,Trunc(pvt.y)+2);
          LineTo   (Trunc(pvt.x)+60,Trunc(pvt.y));
          Pen.Color:=clBlue;
          Line     (Trunc(pvt.x),   Trunc(pvt.y),
                    Trunc(pvt.x),   Trunc(pvt.y)-60);
          LineTo   (Trunc(pvt.x)-2, Trunc(pvt.y)-50);
          LineTo   (Trunc(pvt.x)+2, Trunc(pvt.y)-50);
          LineTo   (Trunc(pvt.x),   Trunc(pvt.y)-60);
          }
          Brush.Style:=bsSolid;
          Pen.Width:=1;
        end;
    end;
end; {$endregion}
procedure TPivot.PivotDraw(constref shift:TPtPos);                                                         inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with srf_var.srf_bmp do
    begin
      Canvas.Draw(Trunc(pvt.x-7),
                  Trunc(pvt.y-7),
                  pvt_bmp);
      PivotModeDraw(Canvas);
      PivotAxisDraw(Canvas,pvt_axis_rect,shift);
      //SelectionToolsMarkerDraw(Trunc(pvt.x)+100,Trunc(pvt.y)-sel_tls_mrk.bmp_ftimg_width>>1);
      if pvt_marker_draw then
        PivotMarkerDraw(Canvas);
    end;
end; {$endregion}
{$endregion}

// (Select Texture Region) Выделить область текстуры(фона):
{LI} {$region -fold}
procedure TF_MainForm.SB_Select_Texture_RegionClick(sender:TObject);

  procedure FillArrTest    (constref bmp_dst_ptr:PInteger; constref rct_dst:TPtRect; constref bmp_dst_width:integer); {$ifdef Linux}[local];{$endif} {$region -fold}
  var
    dst_pixel_ptr: PInteger;
    x,y          : integer;
  begin
    {dst_pixel_ptr:=Unaligned(bmp_dst_ptr+rct_dst.left+rct_dst.top*bmp_dst_width);
    Prefetch(dst_pixel_ptr);
    for y:=0 to rct_dst.height-1 do
      begin
        for x:=0 to rct_dst.width-1 do
          if ((dst_pixel_ptr+x)^=clRed{srf_var.bg_color}) then
            {(dst_pixel_ptr+x)^:=}{clBlack}BorderPixCh(dst_pixel_ptr+x,bmp_dst_width,clRed{srf_var.bg_color});
          {if ((dst_pixel_ptr+x)^=clRed{srf_var.bg_color}) then
            (dst_pixel_ptr+x)^:=RGB((Byte(    ((dst_pixel_ptr+x-bmp_dst_width-1)^)>>00)+Byte(    ((dst_pixel_ptr+x-bmp_dst_width+1)^)>>00)+Byte(    ((dst_pixel_ptr+x+bmp_dst_width-1)^)>>00)+Byte(    ((dst_pixel_ptr+x+bmp_dst_width+1)^)>>00))>>2,
                                    (Byte(Word((dst_pixel_ptr+x-bmp_dst_width-1)^)>>08)+Byte(Word((dst_pixel_ptr+x-bmp_dst_width+1)^)>>08)+Byte(Word((dst_pixel_ptr+x+bmp_dst_width-1)^)>>08)+Byte(Word((dst_pixel_ptr+x+bmp_dst_width+1)^)>>08))>>2,
                                    (Byte(    ((dst_pixel_ptr+x-bmp_dst_width-1)^)>>16)+Byte(    ((dst_pixel_ptr+x-bmp_dst_width+1)^)>>16)+Byte(    ((dst_pixel_ptr+x+bmp_dst_width-1)^)>>16)+Byte(    ((dst_pixel_ptr+x+bmp_dst_width+1)^)>>16))>>2);}
        Inc (dst_pixel_ptr,bmp_dst_width);
      end;}
  end; {$endregion}

  procedure PPFloodFillRot1(constref pvt:TPtPos; constref bmp_src_ptr:PInteger; var bmp_dst_ptr:PInteger; constref rct_dst,rct_clp:TPtRect; constref bmp_dst_width:longword; constref col:integer; constref angle:double); {$region -fold}
  var
    bmp_src_ptr2: PInteger;
    bmp_dst_ptr2: PInteger;
    c,s         : extended;
    r,a         : double;
    x,y,dx,dy   : integer;
    d_width     : integer;
  begin
    a           :=pi/2{10*(pi/180)};
    d_width     :=bmp_dst_width-rct_dst.width;
    bmp_src_ptr2:=@bmp_src_ptr[0{rct_dst.left+rct_dst.top*bmp_dst_width}];
    bmp_dst_ptr2:=@bmp_dst_ptr[0{rct_dst.left+rct_dst.top*bmp_dst_width}];
    for y:=0 to rct_dst.height-1 do
      begin
        for x:=0 to rct_dst.width-1 do
          begin
            r:=sqrt((x-pvt.x)*(x-pvt.x)+(y-pvt.y)*(y-pvt.y));
            SinCos(a+Arctan2((y-pvt.y),(x-pvt.x)),s,c);
            {s:=Sin(Arctan2((y-pvt.y),(x-pvt.x)));
            c:=Cos(Arctan2((y-pvt.y),(x-pvt.x)));}
            if (x>rct_clp.left) and (x<rct_clp.right -1) and
               (y>rct_clp.top ) and (y<rct_clp.bottom-1) then
              if (round(pvt.x+r*c)>rct_clp.left) and (round(pvt.x+r*c)<rct_clp.right -1) and
                 (round(pvt.y+r*s)>rct_clp.top ) and (round(pvt.y+r*s)<rct_clp.bottom-1) then
              bmp_dst_ptr2[(x{-pvt.x}{+rct_dst.left})+(y{-pvt.y}{+rct_dst.top})*bmp_dst_width]:=bmp_src_ptr2[round(pvt.x+r*c)+round(pvt.y+r*s)*bmp_dst_width];
          end;{
        Inc(bmp_src_ptr2,bmp_dst_width);}
      end;
  end; {$endregion}

  procedure BlurEmpty      (arr_src_ptr:PInteger; arr_dst_ptr:PInteger; constref bmp_dst_width,bmp_dst_height:longword); {$region -fold}
  var
    x,y  : integer;
    r,g,b: byte;
  begin
    for y:=0 to bmp_dst_height-1 do
      begin

        for x:=0 to bmp_dst_width-1 do
          begin
            if (y>1) and (y<bmp_dst_height-1) then
            if (arr_src_ptr^=0) then
              begin
                r:=(Red  ((arr_dst_ptr-bmp_dst_width-1)^){+Red  ((arr_dst_ptr-bmp_dst_width)^)}{+Red  ((arr_dst_ptr-bmp_dst_width+1)^)}{+Red  ((arr_dst_ptr-1)^)+Red  ((arr_dst_ptr+1)^)}{+Red  ((arr_dst_ptr+bmp_dst_width-1)^)}{+Red  ((arr_dst_ptr+bmp_dst_width)^)}+Red  ((arr_dst_ptr+bmp_dst_width+1)^))>>1{2}{3};
                g:=(Green((arr_dst_ptr-bmp_dst_width-1)^){+Green((arr_dst_ptr-bmp_dst_width)^)}{+Green((arr_dst_ptr-bmp_dst_width+1)^)}{+Green((arr_dst_ptr-1)^)+Green((arr_dst_ptr+1)^)}{+Green((arr_dst_ptr+bmp_dst_width-1)^)}{+Green((arr_dst_ptr+bmp_dst_width)^)}+Green((arr_dst_ptr+bmp_dst_width+1)^))>>1{2}{3};
                b:=(Blue ((arr_dst_ptr-bmp_dst_width-1)^){+Blue ((arr_dst_ptr-bmp_dst_width)^)}{+Blue ((arr_dst_ptr-bmp_dst_width+1)^)}{+Blue ((arr_dst_ptr-1)^)+Blue ((arr_dst_ptr+1)^)}{+Blue ((arr_dst_ptr+bmp_dst_width-1)^)}{+Blue ((arr_dst_ptr+bmp_dst_width)^)}+Blue ((arr_dst_ptr+bmp_dst_width+1)^))>>1{2}{3};
                arr_dst_ptr^:=RGB(r,g,b);
              end;
            Inc(arr_src_ptr);
            Inc(arr_dst_ptr);
          end;
      end;
  end; {$endregion}

  var
    i       : integer   ;
    col_info: TColorInfo;
    pt      : TPtPos    ;
    pt2     : TPtPosF   ;
    pt3     : TLnPosF   ;
    pt4     : TCrPosF   ;
    pt5     : TPtPosF   ;
    ln_sht  : double    ;
    dir_x   : shortint  ;
    dir_y   : shortint  ;
    l1,l2   : integer   ;
    ex_file : string    ;
    params  : string    ;

begin
  DrawingPanelsSetVisibility1(down_select_texture_region_ptr,P_Select_Texture_Region,P_Draw_Custom_Panel,prev_panel_draw,curr_panel_draw);
  DrawingPanelsSetVisibility2;
  CnvToCnv(srf_var.srf_bmp_rct,Canvas,srf_var.test_bmp.Canvas,SRCCOPY);
  //InvalidateInnerWindow;
end;
{$endregion}

// (Buttons Cursors) Курсоры для кнопок:
{LI} {$region -fold}
procedure CursorInit(constref cur_ind,im_lst_ind:integer; constref location:string; constref ImgLstGetBmp:TProc1); {$region -fold}
var
  bmp_alpha,bmp_color: Graphics.TBitmap; // кастомные иконки для курсоров
  icon_info          : TIconInfo;
begin
  if FileExists(location) then
    begin
      bmp_alpha:=CrtTPicInstFromHDDSrc(location).Bitmap;
      bmp_color:=CrtTPicInstFromHDDSrc(location).Bitmap;
    end
  else
    begin
      bmp_alpha:=CrtTBmpInstFromImgLst(ImgLstGetBmp,im_lst_ind);
      bmp_color:=CrtTBmpInstFromImgLst(ImgLstGetBmp,im_lst_ind);
    end;
  with icon_info do
    begin
      fIcon   :=false;
      xHotspot:=8;
      yHotspot:=22;
      hbmMask :=bmp_alpha.Handle;
      hbmColor:=bmp_color.Handle;
    end;
  Screen.Cursors[cur_ind]:=CreateIconIndirect(icon_info);
  bmp_alpha.Free;
  bmp_color.Free;
end; {$endregion}
{$endregion}

// (Animation) Анимация:
{LI} {$region -fold}
procedure TimeLineButtonsCreate;                                        inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  // Create Buttons Array:
  SetLength(tmln_btn_arr,6);
  // Create Button Background Array:
  SetLength(bckgd_btn_arr,4);
  // Create Buttons Positions Array:
  SetLength(btn_pos_arr,6);
  // Create Buttons Icons:
  with srf_var do
    for i:=0 to 5 do
      tmln_btn_arr[i]:=TFastImage.Create(srf_bmp_ptr,
                                         srf_bmp.width,
                                         srf_bmp.height,
                                         inn_wnd_rct,
                                         max_sprite_w_h_rct,
                                         Application.Location+TIMELINE_BUTTON_ICON_PREFIX+IntToStr(i)+'.png',
                                         @F_MainForm.IL_Butons_Icons.GetBitmap,
                                         i);
  // Create Button Background:
  with srf_var do
    for i:=0 to 3 do
      bckgd_btn_arr[i]:=TFastImage.Create(srf_bmp_ptr,
                                          srf_bmp.width,
                                          srf_bmp.height,
                                          inn_wnd_rct,
                                          max_sprite_w_h_rct,
                                          Application.Location+TIMELINE_BUTTON_ICON_PREFIX+IntToStr(6+i)+'.png',
                                          @F_MainForm.IL_Buttons_Background.GetBitmap,
                                          i);
  // Drawing Settings: Buttons Icons:
  for i in [0,1,2,3,4,5] do
    with tmln_btn_arr[i] do
      begin
        SetPPInfo($0036261D);

        col_trans_arr[03]:=32;

        pix_drw_type             :=1; //must be in range of [0..002]
        nt_pix_srf_type          :=1; //must be in range of [0..002]
        nt_pix_cfx_type          :=2; //must be in range of [0..002]
        nt_pix_cng_type          :=0; //must be in range of [0..001]
        pt_pix_srf_type          :=1; //must be in range of [0..002]
        pt_pix_cfx_type          :=2; //must be in range of [0..002]
        pt_pix_cng_type          :=0; //must be in range of [0..001]

        fx_cnt                   :=1; //must be in range of [0..255]

        fx_arr[0].rep_cnt        :=1; //must be in range of [0..255]
        fx_arr[0].nt_pix_srf_type:=1; //must be in range of [0..001]
        fx_arr[0].nt_pix_cfx_type:=3; //must be in range of [0..255]
        fx_arr[0].nt_pix_cng_type:=1; //must be in range of [0..001]
        fx_arr[0].pt_pix_srf_type:=1; //must be in range of [0..001]
        fx_arr[0].pt_pix_cfx_type:=3; //must be in range of [0..255]
        fx_arr[0].pt_pix_cng_type:=1; //must be in range of [0..001]

        fx_arr[1].rep_cnt        :=1; //must be in range of [0..255]
        fx_arr[1].nt_pix_srf_type:=1; //must be in range of [0..001]
        fx_arr[1].nt_pix_cfx_type:=4; //must be in range of [0..255]
        fx_arr[1].nt_pix_cng_type:=1; //must be in range of [0..001]
        fx_arr[1].pt_pix_srf_type:=1; //must be in range of [0..001]
        fx_arr[1].pt_pix_cfx_type:=4; //must be in range of [0..255]
        fx_arr[1].pt_pix_cng_type:=1; //must be in range of [0..001]
      end;
  // Drawing Settings: Button Background:
  with bckgd_btn_arr[0] do
    begin
      SetPPInfo(clLtGray);

      //col_trans_arr[02]:=200;

      pix_drw_type             :=1; //must be in range of [0..002]
      nt_pix_srf_type          :=1; //must be in range of [0..002]
      nt_pix_cfx_type          :=2; //must be in range of [0..002]
      nt_pix_cng_type          :=0; //must be in range of [0..001]
      pt_pix_srf_type          :=1; //must be in range of [0..002]
      pt_pix_cfx_type          :=2; //must be in range of [0..002]
      pt_pix_cng_type          :=0; //must be in range of [0..001]

      fx_cnt                   :=1; //must be in range of [0..255]

      fx_arr[0].rep_cnt        :=1; //must be in range of [0..255]
      fx_arr[0].nt_pix_srf_type:=1; //must be in range of [0..001]
      fx_arr[0].nt_pix_cfx_type:=0; //must be in range of [0..255]
      fx_arr[0].nt_pix_cng_type:=1; //must be in range of [0..001]
      fx_arr[0].pt_pix_srf_type:=1; //must be in range of [0..001]
      fx_arr[0].pt_pix_cfx_type:=0; //must be in range of [0..255]
      fx_arr[0].pt_pix_cng_type:=1; //must be in range of [0..001]

      fx_arr[1].rep_cnt        :=1; //must be in range of [0..255]
      fx_arr[1].nt_pix_srf_type:=1; //must be in range of [0..001]
      fx_arr[1].nt_pix_cfx_type:=9; //must be in range of [0..255]
      fx_arr[1].nt_pix_cng_type:=1; //must be in range of [0..001]
      fx_arr[1].pt_pix_srf_type:=1; //must be in range of [0..001]
      fx_arr[1].pt_pix_cfx_type:=9; //must be in range of [0..255]
      fx_arr[1].pt_pix_cng_type:=1; //must be in range of [0..001]
    end;
  with bckgd_btn_arr[1] do
    begin
      SetPPInfo(clLtGray);

      //col_trans_arr[02]:=200;

      pix_drw_type             :=1; //must be in range of [0..002]
      nt_pix_srf_type          :=1; //must be in range of [0..002]
      nt_pix_cfx_type          :=2; //must be in range of [0..002]
      nt_pix_cng_type          :=0; //must be in range of [0..001]
      pt_pix_srf_type          :=1; //must be in range of [0..002]
      pt_pix_cfx_type          :=2; //must be in range of [0..002]
      pt_pix_cng_type          :=0; //must be in range of [0..001]

      fx_cnt                   :=1; //must be in range of [0..255]

      fx_arr[0].rep_cnt        :=1; //must be in range of [0..255]
      fx_arr[0].nt_pix_srf_type:=1; //must be in range of [0..001]
      fx_arr[0].nt_pix_cfx_type:=0; //must be in range of [0..255]
      fx_arr[0].nt_pix_cng_type:=1; //must be in range of [0..001]
      fx_arr[0].pt_pix_srf_type:=1; //must be in range of [0..001]
      fx_arr[0].pt_pix_cfx_type:=0; //must be in range of [0..255]
      fx_arr[0].pt_pix_cng_type:=1; //must be in range of [0..001]

      fx_arr[1].rep_cnt        :=1; //must be in range of [0..255]
      fx_arr[1].nt_pix_srf_type:=1; //must be in range of [0..001]
      fx_arr[1].nt_pix_cfx_type:=9; //must be in range of [0..255]
      fx_arr[1].nt_pix_cng_type:=1; //must be in range of [0..001]
      fx_arr[1].pt_pix_srf_type:=1; //must be in range of [0..001]
      fx_arr[1].pt_pix_cfx_type:=9; //must be in range of [0..255]
      fx_arr[1].pt_pix_cng_type:=1; //must be in range of [0..001]
    end;
end; {$endregion}
procedure CursorsCreate;                                                inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  // Create Cursors Array:
  SetLength(cur_arr,1);
  // Create Cursor Icon:
  with srf_var do
    cur_arr[0]:=TFastImage.Create(srf_bmp_ptr,
                                  srf_bmp.width,
                                  srf_bmp.height,
                                  inn_wnd_rct,
                                  max_sprite_w_h_rct,
                                  Application.Location+DEFAULT_CURSOR_ICON,
                                  @F_MainForm.IL_Cursors_Icons.GetBitmap,
                                  0);
  // Drawing Settings:
  {with cur_arr[0] do
    begin
      SetPPInfo(clLtGray);

      //col_trans_arr[02]:=200;

      pix_drw_type             :=1; //must be in range of [0..002]
      nt_pix_srf_type          :=1; //must be in range of [0..002]
      nt_pix_cfx_type          :=2; //must be in range of [0..002]
      nt_pix_cng_type          :=0; //must be in range of [0..001]
      pt_pix_srf_type          :=1; //must be in range of [0..002]
      pt_pix_cfx_type          :=2; //must be in range of [0..002]
      pt_pix_cng_type          :=0; //must be in range of [0..001]

      fx_cnt                   :=1; //must be in range of [0..255]

      fx_arr[0].rep_cnt        :=1; //must be in range of [0..255]
      fx_arr[0].nt_pix_srf_type:=1; //must be in range of [0..001]
      fx_arr[0].nt_pix_cfx_type:=0; //must be in range of [0..255]
      fx_arr[0].nt_pix_cng_type:=1; //must be in range of [0..001]
      fx_arr[0].pt_pix_srf_type:=1; //must be in range of [0..001]
      fx_arr[0].pt_pix_cfx_type:=0; //must be in range of [0..255]
      fx_arr[0].pt_pix_cng_type:=1; //must be in range of [0..001]

      fx_arr[1].rep_cnt        :=1; //must be in range of [0..255]
      fx_arr[1].nt_pix_srf_type:=1; //must be in range of [0..001]
      fx_arr[1].nt_pix_cfx_type:=9; //must be in range of [0..255]
      fx_arr[1].nt_pix_cng_type:=1; //must be in range of [0..001]
      fx_arr[1].pt_pix_srf_type:=1; //must be in range of [0..001]
      fx_arr[1].pt_pix_cfx_type:=9; //must be in range of [0..255]
      fx_arr[1].pt_pix_cng_type:=1; //must be in range of [0..001]
    end;}
end; {$endregion}
procedure TimeLineButtonsDraw(constref x,y:integer);                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  {x:=F_MainForm.S_Splitter2.Top-40;
  y:=F_MainForm.S_Splitter2.Width>>1-16+4;}
  btn_pos_arr[0].x:=y-80;
  btn_pos_arr[0].y:=x;
  btn_pos_arr[1].x:=y-40;
  btn_pos_arr[1].y:=x;
  btn_pos_arr[2].x:=y;
  btn_pos_arr[2].y:=x;
  btn_pos_arr[3].x:=y;
  btn_pos_arr[3].y:=x;
  btn_pos_arr[4].x:=y+40;
  btn_pos_arr[4].y:=x;
  btn_pos_arr[5].x:=y+80;
  btn_pos_arr[5].y:=x;
  for i in [0,1,2,4,5] do
    with bckgd_btn_arr[1] do
      begin
        SetRctPos(btn_pos_arr[i].x,
                  btn_pos_arr[i].y);
        SdrProc[3];
      end;
  for i in [0,1,2,4,5] do
    with tmln_btn_arr[i] do
      begin
        SetRctPos(btn_pos_arr[i].x,
                  btn_pos_arr[i].y);
        SdrProc[3];
      end;
  {for i in [0,1,2,4,5] do
    with bckgd_btn_arr[3] do
      begin
        SetRctPos(btn_pos_arr[i].x,
                  btn_pos_arr[i].y);
        SdrProc[3];
      end;}
end; {$endregion}
procedure CursorDraw(constref x,y:integer; constref cur_ind:integer=0); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with cur_arr[cur_ind] do
    begin
      SetRctPos(x,y);
      SdrProc[3];
    end;
end; {$endregion}
procedure CursorDraw;                                                   inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  with srf_var do
    if IsPtInRct(cur_pos.x,cur_pos.y,inn_wnd_rct) then
      begin
        CursorDraw(cur_pos.x,cur_pos.y);
        CircleHighlight(cur_pos.x,cur_pos.y,
                        srf_bmp_ptr,
                        inn_wnd_rct,
                        srf_bmp.width,
                        Default(TColorInfo),
                        128,
                        045);
      end;
end; {$endregion}
//...
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.OpenGLControl2Click   (sender:TObject); {$region -fold}
begin

end; {$endregion}
procedure TF_MainForm.SB_Play_AnimClick     (sender:TObject); {$region -fold}
var
  i: integer;
begin

  with tlm_var do
    if (Length(tilemap_arr2)<>0) then
      begin
        with tilemap_arr2[High(tilemap_arr2)],sln_prop_var do
          begin
            pts_col_inv       :=SetColorInv(clRed);
            pts_rct_inn_width :=tilemap_sprite_w_h.x-(pts_rct_tns_left+pts_rct_tns_right );
            pts_rct_inn_height:=tilemap_sprite_w_h.y-(pts_rct_tns_top +pts_rct_tns_bottom);
            SetRctWidth (sln_prop_var);
            SetRctHeight(sln_prop_var);
            SetRctValues(sln_prop_var);
          end;
      end;

  if down_play_anim_ptr^ then
    begin
      //srf_var.bg_color:=clBlack;
    end
  else
    begin
      srf_var.bg_color      :=clDkGray;
      T_Logo1.Enabled       :=False;
      T_Logo2.Enabled       :=False;
      T_Logo3.Enabled       :=False;
      T_Menu .Enabled       :=False;
      T_Game .Enabled       :=False;
      {OpenGLControl2.Visible:=False;
      OpenGLControl2.Enabled:=False;}
      time_interval         :=0;
    end;

  with srf_var do
    main_char_pos:=PtPos(world_axis.x+world_axis_shift.x+main_char_pos_spawn_arr[Random(6)].x,
                         world_axis.y+world_axis_shift.y+main_char_pos_spawn_arr[Random(6)].y);

  with srf_var do
    Logo1_img.SetBkgnd(srf_bmp_ptr,srf_bmp.width,srf_bmp.height);
  with srf_var do
    Logo2_img.SetBkgnd(srf_bmp_ptr,srf_bmp.width,srf_bmp.height);

  //LCLVLCPlayer_Intro.PlayFile(Application.Location+INTRO_MOVIE);

  {if down_play_anim_ptr^ then
    mciSendString(PChar('play "C:\Popl_Uniy_Orel.wav"' ),nil,0,0)
  else
    mciSendString(PChar('stop "C:\Popl_Uniy_Orel.wav"'),nil,0,0);}

  OpenGLControl2.Visible:=down_play_anim_ptr^;
  OpenGLControl2.Enabled:=down_play_anim_ptr^;
  with srf_var do
    begin
      // Get Target Render For OpenGL Output:
      GLBitmapToRect(texture_id,srf_bmp,down_play_anim_ptr^);
      //if down_play_anim_ptr^ then
      GetObject(srf_bmp.Handle,SizeOf(buffer),@buffer);
    end;

  for i:=0 to 9999 do
    begin
      projectile_arr[i]:=projectile_default;
      with projectile_arr[i] do
        begin
          pt_ind:=-1;
          pt_0  :=PtPosF(srf_var.world_axis.x,
                         srf_var.world_axis.y);
          pt_p  :=pt_0;
          pt_n  :=pt_0;
          //pt_c :=pt_n;
          {v_0  +=Random(12);
          angle+=Random(90);}
          //projectile_arr[i].time-=TIME_DELTA;
        end;
    end;

  DrawingPanelsSetVisibility1(down_play_anim_ptr,P_Play_Anim,P_AnimK_Custom_Panel,prev_panel_animk,curr_panel_animk);
  DrawingPanelsSetVisibility2;

  {TODO}
  BB_Use_MagicClick(self);


  with srf_var do
    if down_play_anim_ptr^ then
      SetBkgnd
      (
        low_bmp_ptr,
        low_bmp.width,
        low_bmp.height,
        inn_wnd_rct
      )
    else
      SetBkgnd
      (
        srf_bmp_ptr,
        srf_bmp.width,
        srf_bmp.height,
        inn_wnd_rct
      );



  T_Game_Loop.Enabled:=down_play_anim_ptr^;
  //T_Logo1.Enabled:=down_play_anim_ptr^;


  VisibilityChange      (not down_play_anim_ptr^);
  show_visibility_panel:=not down_play_anim_ptr^;
  if (not down_play_anim_ptr^) then
    begin
      VisibilityChange(True);
      show_visibility_panel:=True;
    end;
  {with sln_var,fast_fluid_var do
    if (sln_pts_cnt<>0) then
      WaterWaveInit(sln_pts,
                    sln_pts_cnt-sln_obj_pts_cnt[sln_obj_cnt-1],
                    sln_pts_cnt);}
end; {$endregion}
procedure TF_MainForm.BB_Load_FrameClick    (sender:TObject); {$region -fold}
var
  button_glyph: Graphics.TBitmap;
begin
  OpenPictureDialog1.Options:=OpenPictureDialog1.Options+[ofFileMustExist];
  if (not OpenPictureDialog1.Execute) then
    Exit;
  try
    sln_var.tex_on_sln.LoadFromFile(OpenPictureDialog1.Filename);
  except
    on E: Exception do
      MessageDlg('Error','Error: '+E.Message,mtError,[mbOk],0);
  end;
  button_glyph       :=Graphics.TBitmap.Create;
  button_glyph.Width :=50;
  button_glyph.Height:=50;
  button_glyph.PixelFormat:=pf32bit;
  button_glyph.Canvas.StretchDraw(Rect(0,0,
                                       button_glyph.Width,
                                       button_glyph.Height),
                                       sln_var.tex_on_sln.Graphic);
  BB_Load_Bitmap.Glyph:=button_glyph;
  sln_var.tex_on_sln_tmp_bmp:=Graphics.TBitmap.Create;

end; {$endregion}
procedure TF_MainForm.BB_Use_MagicClick     (sender:TObject); {$region -fold}
var
  sprite_rect_arr_ptr: PPtPos;
  useless_arr_ptr    : PByte;
  i,v1,v2,c0,c1,c2,c3: integer;
begin

  {if (useless_fld_arr_<>Nil) then
    //ArrClear(useless_fld_arr_,srf_var.inn_wnd_rct,srf_var.srf_bmp.width);
    FillDWord((@useless_fld_arr_[0])^,srf_var.srf_bmp.width*srf_var.srf_bmp.height,0);}
  SetLength(useless_fld_arr_,srf_var.srf_bmp.width*srf_var.srf_bmp.height);
  ArrClear(useless_fld_arr_,srf_var.inn_wnd_rct,srf_var.srf_bmp.width);

 {if (useless_arr_<>Nil) then
    FillByte ((@useless_arr_[0])^,SE_Count_X.value,0);}
  SetLength  (  useless_arr_     ,SE_Count_X.value  );
  FillByte   ((@useless_arr_[0])^,SE_Count_X.value,0);

  {if (sprite_rect_arr_<>Nil) then
    FillQWord((@sprite_rect_arr_[0])^,SE_Count_X.value,0);}
  SetLength(sprite_rect_arr,SE_Count_X.value);
  FillQWord((@sprite_rect_arr[0])^,SE_Count_X.value,0);

  v1:=Trunc(tex_var.tex_bmp_rct_pts[0].x)-fast_actor_set_var.d_icon.bmp_ftimg_width >>1;
  v2:=Trunc(tex_var.tex_bmp_rct_pts[0].y)-fast_actor_set_var.d_icon.bmp_ftimg_height>>1;
  sprite_rect_arr_ptr:=@sprite_rect_arr[0];
  for i:=0 to SE_Count_X.Value-1 do
    begin
      sprite_rect_arr_ptr^.x:=v1+Random(Trunc(tex_var.tex_bmp_rct_pts[1].x-tex_var.tex_bmp_rct_pts[0].x));
      sprite_rect_arr_ptr^.y:=v2+Random(Trunc(tex_var.tex_bmp_rct_pts[1].y-tex_var.tex_bmp_rct_pts[0].y));
      Inc(sprite_rect_arr_ptr);
    end;

  c0:=0;
  c1:=0;
  c2:=0;
  c3:=0;
  with fast_actor_set_var.d_icon do
    begin
      sprite_rect_arr_ptr:=@sprite_rect_arr[SE_Count_X.value-1];
      useless_arr_ptr    :=@useless_arr_   [SE_Count_X.value-1];
      for i:=SE_Count_X.Value-1 downto 0 do
        begin
          SetRctPos(sprite_rect_arr_ptr^.x,
                    sprite_rect_arr_ptr^.y);
          Dec      (sprite_rect_arr_ptr);
          SetRctDst;
          SetRctSrc;
          NTUselessProc[nt_pix_clp_type](useless_fld_arr_,srf_var.srf_bmp.Width,i);
          PTUselessProc[pt_pix_clp_type](useless_fld_arr_,srf_var.srf_bmp.Width,i);
          useless_arr_ptr^:=Useless;
          case useless_arr_ptr^ of
            0: Inc(c0);
            1: Inc(c1);
            2: Inc(c2);
            3: Inc(c3);
          end;
          Dec(useless_arr_ptr);
        end;
    end;

  {Memo1.Lines.Text:=IntToStr({fast_actor_set_var.d_icon.img_kind}{nt_pix_cnt}c0)+'; '+
                    IntToStr({fast_actor_set_var.d_icon.img_kind}{nt_pix_cnt}c1)+'; '+
                    IntToStr({fast_actor_set_var.d_icon.img_kind}{nt_pix_cnt}c2)+'; '+
                    IntToStr({fast_actor_set_var.d_icon.img_kind}{nt_pix_cnt}c3)+'. ';}

  {anim_play2:=not anim_play2;
  if anim_play2 then
    Application.OnIdle:=@Tic
  else
    Application.OnIdle:=Nil;}

end; {$endregion}
procedure TF_MainForm.I_Frame_ListMouseEnter(sender:TObject); {$region -fold}
begin
  with fast_actor_set_var.d_icon,add_actor_var do
    begin
      SetBkgnd (img_lst_bmp_ptr,img_lst_bmp.width,img_lst_bmp.height);
      SetClpRct(bmp_rect);
    end;
end; {$endregion}
procedure TF_MainForm.I_Frame_ListMouseDown (sender:TObject; button:TMouseButton; shift:TShiftState; x,y:integer); {$region -fold}
begin
  fast_actor_set_var.AddActor(x,y);
  CnvToCnv(PtBounds(0,0,img_lst_bmp.Width,img_lst_bmp.Height),
           I_Frame_List.Canvas,
           img_lst_bmp.Canvas,
           SRCCOPY);
  I_Frame_List.Invalidate;
end; {$endregion}
{$endregion}

// (Map Editor) Редактор карт:
{LI} {$region -fold}
constructor TTlMap.Create;                                          {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  TileMapSpriteDefaultIconCreate;
  show_tile_map:=True;
end; {$endregion}
destructor  TTlMap.Destroy;                                         {$ifdef Linux}[local];{$endif} {$region -fold}
begin
end; {$endregion}
procedure  TTlMap.TileMapSpriteDefaultIconCreate;           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  // Create Mask Template Sprite Icon:
  with srf_var do
    tilemap_sprite_icon:=TFastImage.Create(srf_bmp_ptr,
                                           srf_bmp.width,
                                           srf_bmp.height,
                                           inn_wnd_rct,
                                           max_sprite_w_h_rct,
                                           Application.Location+DEFAULT_TILE_MAP_SPRITE_ICON,
                                           @F_MainForm.IL_Default_Mask_Template_Sprite_Icon.GetBitmap,
                                           0);
end; {$endregion}
procedure  TTlMap.AddTileMapObj(constref rct_out:TPtRect);  inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rct_out_            : TPtRect;
  default_tlmap_sprite: string;
begin
  with srf_var,tlm_var do
    begin
      {Load Picture}
      SetLength(tilemap_arr1,
         Length(tilemap_arr1)+1);
      default_tlmap_sprite            :={Application.Location+DEFAULT_TILE_MAP_ICON}F_MainForm.OPD_Add_Mask_Template.Filename;
      tilemap_arr1[High(tilemap_arr1)]:=TPicture.Create;
      tilemap_arr1[High(tilemap_arr1)].LoadFromFile(default_tlmap_sprite);
      if (not FileExists(default_tlmap_sprite)) then
      begin
        tilemap_arr1[High(tilemap_arr1)].Bitmap:=Graphics.TBitmap.Create;
        with tilemap_arr1[High(tilemap_arr1)].Bitmap do
          begin
            Width      :=F_MainForm.IL_Default_Tile_Map_Icon.width;
            Height     :=F_MainForm.IL_Default_Tile_Map_Icon.height;
            F_MainForm.IL_Default_Tile_Map_Icon.GetBitmap(0,tilemap_arr1[High(tilemap_arr1)].Bitmap);
          end;
      end;

      {Compress Picture}
      SetLength(tilemap_arr2,
         Length(tilemap_arr2)+1);
      rct_out_:=rct_out;
      tilemap_arr2[High(tilemap_arr2)]:=TFastImage.Create(srf_bmp_ptr,
                                                          srf_bmp.width,
                                                          srf_bmp.height,
                                                          rct_out_,
                                                          max_sprite_w_h_rct,
                                                          default_tlmap_sprite,
                                                          @F_MainForm.IL_Default_Tile_Map_Icon.GetBitmap,
                                                          0,
                                                          True,
                                                          tilemap_arr1[High(tilemap_arr1)]);
      with tilemap_arr2[High(tilemap_arr2)] do
        begin
          tilemap_sprite_w_h:=PtPos    ( tilemap_sprite_icon.bmp_ftimg_width_origin,
                                         tilemap_sprite_icon.bmp_ftimg_height_origin);
          tilemap_sprite_ptr:=Unaligned(@tilemap_sprite_icon                        );
        end;
    end;
end; {$endregion}
procedure  TTlMap.AddTileMapPreview;                        inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rct1,rct2: TRect;
begin
  with srf_var,tlm_var do
    begin
      rct1:=Bounds(0,
                   0,
                   tilemap_arr1[High(tilemap_arr1)].width,
                   tilemap_arr1[High(tilemap_arr1)].height);
      rct2:=Bounds(0,
                   0,
                   100,
                   100);
      F_MainForm.I_Add_Mask_Template_List.Canvas.CopyRect(rct2,tilemap_arr1[High(tilemap_arr1)].Bitmap.Canvas,rct1);
    end;
end; {$endregion}
procedure  TTlMap.FilTileMapObj(constref tlmap_ind:TColor); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
begin
  if show_tile_map then
    with srf_var,tilemap_arr2[tlmap_ind] do
      begin
        obj_arr_ptr:=Unaligned(@obj_var.obj_arr[obj_var.tlmap_inds_obj_arr[tlmap_ind]]);
        SetRctPos(world_axis.x-(bmp_ftimg_width_origin *tilemap_sprite_w_h.x)>>1+obj_arr_ptr^.world_axis_shift.x,
                  world_axis.y-(bmp_ftimg_height_origin*tilemap_sprite_w_h.y)>>1+obj_arr_ptr^.world_axis_shift.y);
        SetBkgnd
        (
          srf_bmp_ptr,
          srf_bmp.width,
          srf_bmp.height
        );
        with tilemap_sprite_ptr^ do
          SetBkgnd
          (
            srf_bmp_ptr,
            srf_bmp.width,
            srf_bmp.height
          );
        FilMaskTemplate1;
        bmp_bkgnd_ptr:=@coll_arr[0];
      end;
end; {$endregion}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.SB_Map_EditorClick (sender:TObject); {$region -fold}
begin
  DrawingPanelsSetVisibility1(down_map_editor_ptr,P_Map_Editor,P_AnimK_Custom_Panel,prev_panel_animk,curr_panel_animk);
end; {$endregion}
procedure TF_MainForm.BB_Add_TilemapClick(sender:TObject); {$region -fold}
begin
  with srf_var,tlm_var do
    begin
      OPD_Add_Mask_Template.Options:=OPD_Add_Mask_Template.Options+[ofFileMustExist];
      if (not OPD_Add_Mask_Template.Execute) then
        Exit;
      try
        AddTileMapObj(inn_wnd_rct);
      except
        on E: Exception do
          MessageDlg('Error','Error: '+E.Message,mtError,[mbOk],0);
      end;
      AddTileMapPreview;
    end;
  srf_var.EventGroupsCalc(calc_arr,[30,39]);
end; {$endregion}
procedure TF_MainForm.BB_Add_SpriteClick (sender:TObject); {$region -fold}
begin

end; {$endregion}
{$endregion}

// (Add Actor) Добавить персонажа:
{LI} {$region -fold}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.SB_Add_ActorClick(sender:TObject); {$region -fold}
begin
  DrawingPanelsSetVisibility1(down_add_actor_ptr,P_Add_Actor,P_AnimK_Custom_Panel,prev_panel_animk,curr_panel_animk);
end; {$endregion}
{$endregion}

// (F_MainForm) Основные функции формы:
{LI} {$region -fold}
procedure SpeedButtonRepaint;                                                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  F_MainForm.TB_Speed.width:=137;
  F_MainForm.TB_Speed.width:=136;
end; {$endregion}
procedure FormChangeSize;                                                                                                   inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  SplittersPosCalc;
  with srf_var do
    begin
      EventGroupsCalc(calc_arr,[0,1,2,3,4,16,17,18,21,22,30,31,32,37]);
      SetLength(useless_fld_arr_,srf_bmp.width*srf_bmp.height);
      ArrClear (useless_fld_arr_,inn_wnd_rct,  srf_bmp.width );
    end;
  if down_select_points_ptr^ then
    sel_var.MinimizeCircleSelection;
end; {$endregion}
procedure MovRight;                                                                                                         inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sprite_rect_arr_ptr: PPtPos;
  j                  : integer;
begin
  with srf_var,sln_var,tex_var,srf_var,tex_var,sln_var,sel_var,pvt_var,fast_physics_var,fast_fluid_var do
    begin
      world_axis_shift.x-=parallax_shift.x;
      obj_var.MovWorldAxisShiftRight;
    end;
end; {$endregion}
procedure FilRight(constref bmp_dst_ptr:PInteger; constref bmp_dst_width,bmp_dst_height:integer; constref rct_dst:TPtRect); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rct: TPtRect;
begin
  with srf_var,sgr_var,rgr_var,sln_var do
    begin
      mov_dir:=mdRight;
      rct:=PtRct
      (
        rct_dst.right-parallax_shift.x,
        rct_dst.top,
        rct_dst.right,
        rct_dst.bottom
      );
      BitBlt1
      (
        bmp_dst_ptr,
        bmp_dst_ptr,
        rct_dst.left +parallax_shift.x,
        rct_dst.top,
        rct_dst.width-parallax_shift.x,
        rct_dst.height,
        rct_dst.left,
        rct_dst.top,
        bmp_dst_width,
        bmp_dst_width
      );
      PPFloodFill(bmp_dst_ptr,rct,bmp_dst_width,bg_color);
      if show_snap_grid then
        SGridToBmp
        (
          PtPosF(world_axis.x+srf_var.world_axis_shift.x,
                 world_axis.y+srf_var.world_axis_shift.y),
          bmp_dst_ptr,
          bmp_dst_width,
          rct
        );
      if show_grid then
        RGridToBmp
        (
          PtPosF(world_axis.x+srf_var.world_axis_shift.x,
                 world_axis.y+srf_var.world_axis_shift.y),
          bmp_dst_ptr,
          bmp_dst_width,
          rct
        );
      if show_spline then
        MovSplineAll
        (
          0,
          sln_obj_cnt-1,
          rct
        );
    end;
end; {$endregion}
procedure MovLeft;                                                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sprite_rect_arr_ptr: PPtPos;
  j                  : integer;
begin
  with srf_var,sln_var,tex_var,srf_var,tex_var,sln_var,sel_var,pvt_var,fast_physics_var,fast_fluid_var do
    begin
      world_axis_shift.x+=parallax_shift.x;
      obj_var.MovWorldAxisShiftLeft;
    end;
end; {$endregion}
procedure FilLeft (constref bmp_dst_ptr:PInteger; constref bmp_dst_width,bmp_dst_height:integer; constref rct_dst:TPtRect); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rct: TPtRect;
begin
  with srf_var,sgr_var,rgr_var,sln_var do
    begin
      mov_dir:=mdLeft;
      rct:=PtRct
      (
        rct_dst.left,
        rct_dst.top,
        rct_dst.left+parallax_shift.x,
        rct_dst.bottom
      );
      BitBlt2
      (
        bmp_dst_ptr,
        bmp_dst_ptr,
        rct_dst.left,
        rct_dst.top,
        rct_dst.width-parallax_shift.x,
        rct_dst.height,
        rct_dst.left +parallax_shift.x,
        rct_dst.top,
        bmp_dst_width,
        bmp_dst_width
      );
      PPFloodFill(bmp_dst_ptr,rct,bmp_dst_width,bg_color);
      if show_snap_grid then
        SGridToBmp
        (
          PtPosF(world_axis.x+srf_var.world_axis_shift.x,
                 world_axis.y+srf_var.world_axis_shift.y),
          bmp_dst_ptr,
          bmp_dst_width,
          rct
        );
      if show_grid then
        RGridToBmp
        (
          PtPosF(world_axis.x+srf_var.world_axis_shift.x,
                 world_axis.y+srf_var.world_axis_shift.y),
          bmp_dst_ptr,
          bmp_dst_width,
          rct
        );
      if show_spline then
        MovSplineAll
        (
          0,
          sln_obj_cnt-1,
          rct
        );
    end;
end; {$endregion}
procedure MovDown;                                                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sprite_rect_arr_ptr: PPtPos;
  j                  : integer;
begin
  with srf_var,sln_var,tex_var,srf_var,tex_var,sln_var,sel_var,pvt_var,fast_physics_var,fast_fluid_var do
    begin
      world_axis_shift.y-=parallax_shift.y;
      obj_var.MovWorldAxisShiftDown;
    end;
end; {$endregion}
procedure FilDown (constref bmp_dst_ptr:PInteger; constref bmp_dst_width,bmp_dst_height:integer; constref rct_dst:TPtRect); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rct: TPtRect;
begin
  with srf_var,sgr_var,rgr_var,sln_var do
    begin
      mov_dir:=mdDown;
      rct:=PtRct
      (
        rct_dst.left,
        rct_dst.bottom-parallax_shift.y,
        rct_dst.right,
        rct_dst.bottom
      );
      BitBlt1
      (
        bmp_dst_ptr,
        bmp_dst_ptr,
        rct_dst.left,
        rct_dst.top   +parallax_shift.y,
        rct_dst.width,
        rct_dst.height-parallax_shift.y,
        rct_dst.left,
        rct_dst.top,
        bmp_dst_width,
        bmp_dst_width
      );
      PPFloodFill(bmp_dst_ptr,rct,bmp_dst_width,bg_color);
      if show_snap_grid then
        SGridToBmp
        (
          PtPosF(world_axis.x+srf_var.world_axis_shift.x,
                 world_axis.y+srf_var.world_axis_shift.y),
          bmp_dst_ptr,
          bmp_dst_width,
          rct
        );
      if show_grid then
        RGridToBmp
        (
          PtPosF(world_axis.x+srf_var.world_axis_shift.x,
                 world_axis.y+srf_var.world_axis_shift.y),
          bmp_dst_ptr,
          bmp_dst_width,
          rct
        );
      if show_spline then
        MovSplineAll
        (
          0,
          sln_obj_cnt-1,
          rct
        );
    end;
end; {$endregion}
procedure MovUp;                                                                                                            inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sprite_rect_arr_ptr: PPtPos;
  j                  : integer;
begin
  with srf_var,sln_var,tex_var,srf_var,tex_var,sln_var,sel_var,pvt_var,fast_physics_var,fast_fluid_var do
    begin
      world_axis_shift.y+=parallax_shift.y;
      obj_var.MovWorldAxisShiftUp;
    end;
end; {$endregion}
procedure FilUp   (constref bmp_dst_ptr:PInteger; constref bmp_dst_width,bmp_dst_height:integer; constref rct_dst:TPtRect); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rct: TPtRect;
begin
  with srf_var,sgr_var,rgr_var,sln_var do
    begin
      mov_dir:=mdUp;
      rct:=PtRct
      (
        rct_dst.left,
        rct_dst.top,
        rct_dst.right,
        rct_dst.top+parallax_shift.y
      );
      BitBlt2
      (
        bmp_dst_ptr,
        bmp_dst_ptr,
        rct_dst.left,
        rct_dst.top,
        rct_dst.width,
        rct_dst.height-parallax_shift.y,
        rct_dst.left,
        rct_dst.top   +parallax_shift.y,
        bmp_dst_width,
        bmp_dst_width
      );
      PPFloodFill(bmp_dst_ptr,rct,bmp_dst_width,bg_color);
      if show_snap_grid then
        SGridToBmp
        (
          PtPosF(world_axis.x+srf_var.world_axis_shift.x,
                 world_axis.y+srf_var.world_axis_shift.y),
          bmp_dst_ptr,
          bmp_dst_width,
          rct
        );
      if show_grid then
        RGridToBmp
        (
          PtPosF(world_axis.x+srf_var.world_axis_shift.x,
                 world_axis.y+srf_var.world_axis_shift.y),
          bmp_dst_ptr,
          bmp_dst_width,
          rct
        );
      if show_spline then
        MovSplineAll
        (
          0,
          sln_obj_cnt-1,
          rct
        );
    end;
end; {$endregion}
{$ifdef Windows}
procedure TF_MainForm.OnMove(var message:TWMMove);                                                                                                                 {$region -fold}
begin
  if move_with_child_form then
    begin
      F_Hot_Keys.Left:=F_MainForm.Left+11;
      F_Hot_Keys.Top :=F_MainForm.Top +80;
    end;
  inherited;
end; {$endregion}
{$endif}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.TB_SpeedChange    (sender:TObject);                                                          {$region -fold}
begin
  srf_var.parallax_shift.x:=TB_Speed.Position;
  srf_var.parallax_shift.y:=TB_Speed.Position;
  main_char_speed         :=TB_Speed.Position;
  obj_var.SetParallaxShift(srf_var.parallax_shift);
end; {$endregion}
procedure TF_MainForm.TB_SpeedClick     (sender:TObject);                                                          {$region -fold}
begin

end; {$endregion}
procedure TF_MainForm.KeysEnable;                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  OnKeyPress:=@FormKeyPress;
  OnKeyDown :=@FormKeyDown;
  OnKeyUp   :=@FormKeyUp;
end; {$endregion}
procedure TF_MainForm.KeysDisable;                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  OnKeyPress:=Nil;
  OnKeyDown :=Nil;
  OnKeyUp   :=Nil;
end; {$endregion}
procedure TF_MainForm.FormResize        (sender:TObject);                                                          {$region -fold}
begin
  FormChangeSize;
end; {$endregion}
procedure TF_MainForm.FormMouseMove     (sender:TObject; shift:TShiftState; x,y:integer);                          {$region -fold}
var
  color_info: TColorInfo;
begin

  if down_play_anim_ptr^ then
    begin
      ////
      Exit;
    end;

  {Selection} {$region -fold}
  if down_select_points_ptr^ then
    begin

      {Move Pivot-----------} {$region -fold}
      if pvt_var.move_pvt then
        case pvt_var.pvt_mode of
          (pmPivotMove  ): {$region -fold}
            with srf_var,sln_var,sel_var,pvt_var do
              begin
                need_repaint:=True;
                LowerBmpToMainBmp;
                {Align Pivot on Axis X}
                AlignPivotOnX             (x,y,shift);
                {Align Pivot on Axis Y}
                AlignPivotOnY             (x,y,shift);
                {Align Pivot on Points}
                AlignPivotOnP             (x,y,shift);
                {Drawing of Outer Subgraph }
                if draw_out_subgraph then
                  OuterSubgraphToBmp      (x,y,pvt,sln_pts,srf_bmp_ptr,inn_wnd_rct);
                {Drawing of Inner Subgraph }
                if draw_inn_subgraph and  (not IsRct1OutOfRct2(sel_var.sel_pts_rct,inn_wnd_rct)) then
                  InnerSubgraphToBmp      (x,y,pvt,sln_pts,srf_bmp_ptr,ClippedRct(inn_wnd_rct,sel_pts_rct));
                {Drawing of Selected Points}
                if draw_selected_pts then
                  SelectdPointsToBmp      (x,y,pvt,sln_pts,srf_bmp_ptr,inn_wnd_rct);
                {--------------------------}
                SelectedPtsBmpPositionCalc(x,y,sel_pts_rct);
                pvt:=PtPosF               (x,y);
                srf_bmp.Canvas.Draw(Trunc(pvt.x-7),Trunc(pvt.y-7),pvt_bmp);
                {if show_selected_pts_b_rect then
                  SelectedPtsRectDraw(srf_bmp.Canvas,
                                      sel_var.sel_pts_rct,
                                      clPurple,
                                      clNavy);}
                PivotModeDraw(srf_bmp.Canvas);
                PivotAxisDraw(srf_bmp.Canvas,pvt_axis_rect,Ptpos(0,0));
                CnvToCnv     (srf_bmp_rct,Canvas,srf_bmp.Canvas,SRCCOPY{NOTSRCCOPY});
                //srf_bmp.Canvas.CopyMode:=cmSrcCopy;
                {$ifdef Windows}
                Sleep(32);
                {$else}
                USleep(32000000);
                {$endif}
                need_repaint:=False;
                Exit;
              end; {$endregion}
          (pmPivotScale ): {$region -fold}
            with srf_var,sel_var do
              begin
                //pvt_var.SelectedPtsScalingCalc(X,Y,sel_pts_var.subgraph_eds);
                LowerBmpToMainBmp;
                {if draw_sel_eds then
                  begin
                    {OuterAndInnerSubgraphToBmp(Trunc(pvt_var.pvt.X),
                                               Trunc(pvt_var.pvt.Y))}
                  end
                else
                  InnerSubgraphToBmp(Trunc(pvt_var.pvt.X),
                                     Trunc(pvt_var.pvt.Y));}
                {sel_pts_var.SelectedPtsToBmp;}
                Exit;
              end; {$endregion}
          (pmPivotRotate): {$region -fold}
            begin

              Exit;
            end; {$endregion}
        end; {$endregion}

      {Circle Selection Mode} {$region -fold}
      if crc_sel_var.draw_crc_sel then
        with srf_var,sln_var,sel_var,crc_sel_var,brs_sel_var do
          begin
            need_repaint:=True;
            if exp0 then
              LowerBmp2ToMainBmp
            else
              LowerBmpToMainBmp;
            if world_axis_draw and (not exp0) then
              WorldAxisDraw;
            VisibilityChange(False);
            ResizeCircleSelectionModeDraw;
            if (not only_fill) then
              begin
                AddCircleSelection;
                CrtCircleSelection;
                only_fill:=True;
              end;
            FilSelPtsObj(crc_sel_rct.left,crc_sel_rct.top); //CircleSelectionModeDraw(x,y,srf_var);
            if sel_var.sel_pts then
              case CB_Select_Points_Selection_Mode.ItemIndex of
                0: CircleSelection(x,y,srf_var,sel_var,sln_pts,sln_pts_cnt,True);
                1:
                  begin
                    SetColorInfo   (clGreen,color_info);
                    CircleFloodFill(x,y,low_bmp_ptr,inn_wnd_rct,low_bmp.width,color_info,crc_rad<<1,120);
                    CircleSelection(x,y,srf_var,sel_var,sln_pts,sln_pts_cnt,False);
                  end;
              end;
            CnvToCnv(srf_bmp_rct,Canvas,srf_bmp.Canvas,SRCCOPY);
            {$ifdef Windows}
            Sleep(1);
            {$else}
            USleep(1000000);
            {$endif}
            need_repaint:=False;
            Exit;
          end; {$endregion}

      {Pivot To Point-------} {$region -fold}
      if pvt_var.pvt_to_pt then
        with srf_var,sln_var,sel_var,crc_sel_var,pvt_var do
          begin
            //VisibilityChange(False);
            need_repaint:=True;
            LowerBmpToMainBmp;
            if draw_selected_pts then
              SelectdPointsToBmp(x,y,pvt,sln_pts,srf_bmp_ptr,inn_wnd_rct);
          //PivotToPoint(x,y,sln_pts,sln_pts_cnt,                  crc_rad_sqr);
            PivotToPoint(x,y,dup_pts_arr,inn_wnd_rct,srf_bmp.width,crc_rad);
            PivotModeDraw(srf_bmp.Canvas);
            PivotAxisDraw(srf_bmp.Canvas,pvt_axis_rect,PtPos(0,0));
            if pvt_to_pt_draw_pt then
              PivotToPointDraw(srf_bmp.Canvas)
            else
              srf_bmp.Canvas.Draw
              (
                Trunc(pvt.x-7),
                Trunc(pvt.y-7),
                pvt_bmp
              );
            CnvToCnv
            (
              srf_bmp_rct,
              Canvas,
              srf_bmp.Canvas,
              SRCCOPY
            );
            {$ifdef Windows}
            Sleep(6);
            {$else}
            USleep(6000000);
            {$endif}
            need_repaint:=False;
            Exit;
          end; {$endregion}

    end; {$endregion}

  {Spline---} {$region -fold}
  with srf_var,sln_var do
    if draw_spline                  and
      ((CB_Spline_Mode.ItemIndex=0) or
      (CB_Spline_Mode.ItemIndex=2)) then
      begin
        if down_play_anim_ptr^ then
          AddPoint
          (
            x,
            y,
            srf_bmp_ptr,
            srf_bmp.width,
            color_info,
            inn_wnd_rct,
            add_spline_calc,
            True
          )
        else
          begin
            //VisibilityChange(False);
            AddPoint
            (
              x,
              y,
              low_bmp_ptr,
              low_bmp.width,
              color_info,
              inn_wnd_rct,
              add_spline_calc,
              True
            );
            CnvToCnv
            (
              srf_bmp_rct,
              Canvas,
              low_bmp.Canvas,
              SRCCOPY
            );
          end;
      end; {$endregion}

end; {$endregion}
procedure TF_MainForm.FormMouseDown     (sender:TObject; button:TMouseButton; shift:TShiftState; x,y:integer);     {$region -fold}
var
  color_info: TColorInfo;
begin
  case Button of

    (mbLeft):
      begin

        {Animation}
        if down_play_anim_ptr^ then
          begin
            vec_x:=x{+35};
            vec_y:=y{-69};
            projectile_var:=projectile_default;
            with projectile_var do
              begin
                pt_0:=PtPosF(x-srf_var.world_axis_shift.x,
                             y-srf_var.world_axis_shift.y);
                pt_p:=pt_0;
                pt_n:=pt_0;
                pt_c:=pt_n;
              end;
            //Exit;
          end;

        {Add Actor}
        if down_add_actor_ptr^ then
          begin
            fast_actor_set_var.AddActor(x,y);
            {with main_canvas_var,tex_canvas_var do
              PPFloodFill(main_bmp_handle,
                          ClippedRect(inner_window_rect,tex_bmp_rect),
                          main_bmp.Width,
                          clGreen);}
              {PPHighLight(main_bmp_handle,
                          ClippedRect(inner_window_rect,tex_bmp_rect),
                          main_bmp.Width);}
              {PPColorCorrection0(@ColorizeRM,
                                 @ColorizeRP,
                                 main_bmp_handle,
                                 ClippedRect(inner_window_rect,tex_bmp_rect),
                                 main_bmp.Width,
                                 sprite_count);} ///////
            with srf_var do
              CnvToCnv(srf_bmp_rct,
                       Canvas,
                       srf_bmp.Canvas,SRCCOPY);
            Exit;
          end;

        {Brush}
        if down_brush_ptr^ then
          begin
            draw_brush:=True;
            PrevX     :=x;
            PrevY     :=y;
          end;

        {Spray}
        if down_spray_ptr^ then
          begin
            draw_spray:=True;
            SprayDraw(x,y,40,CD_Select_Color.Color);
          end;

        if show_spline then
          begin

            {Spline}
            if down_spline_ptr^ then
              with Canvas,srf_var,sln_var do
                if (CB_Spline_Type.ItemIndex=0) then
                  begin
                    draw_spline:=not draw_spline;
                    VisibilityChange(False);
                    case CB_Spline_Mode.ItemIndex of
                      0,2:
                        MoveTo(x,y);
                      1:
                        begin
                          AddPoint
                          (
                            x,
                            y,
                            srf_bmp_ptr,
                            srf_bmp.width,
                            color_info,
                            inn_wnd_rct,
                            add_spline_calc
                          );
                          CnvToCnv
                          (
                            srf_bmp_rct,
                            Canvas,
                            srf_bmp.Canvas,
                            SRCCOPY
                          );
                        end;
                    end;
                  end;

            if down_select_points_ptr^ then
              with sln_var,sel_var,pvt_var,crc_sel_var,brs_sel_var do
                begin

                  resize_crc_sel:=False;
                  draw_brs_sel  :=False;
                  pvt_to_pt     :=False;

                  {Select Pivot}
                  if need_align_pivot_x then
                    y:=align_pivot.y;
                  if need_align_pivot_y then
                    x:=align_pivot.x;
                  if need_align_pivot_p then
                    begin
                      x:=align_pivot.x;
                      y:=align_pivot.y;
                    end;
                  if ((pvt.x-x)*(pvt.x-x)+
                      (pvt.y-y)*(pvt.y-y)<=crc_rad_sqr) then
                    begin
                      move_pvt:=(not move_pvt);
                      if show_visibility_panel then
                        VisibilityChange(not move_pvt);
                      if move_pvt then
                        begin
                          with srf_var do
                            begin
                              need_repaint:=True;
                              LowerBmp2ToMainBmp;
                              CnvToCnv(srf_bmp_rct,Canvas,srf_bmp.Canvas,SRCCOPY);
                              need_repaint:=False;
                            end;
                          pvt_origin    :=pvt;
                          pvt_to_pt     :=False;
                          draw_crc_sel  :=False;
                          resize_crc_sel:=False;
                          crc_sel_rct   :=Default(TRect);
                        end
                      else
                        begin
                          if exp0 then
                            begin
                              with srf_var do
                                begin
                                  need_repaint:=True;
                                  LowerBmpToMainBmp;
                                  SelectedSubgrtaphDraw;
                                  PivotDraw(PtPos(0,0));
                                  MainBmpToLowerBmp2;
                                  CnvToCnv(srf_bmp_rct,Canvas,srf_bmp.Canvas,SRCCOPY);
                                  need_repaint:=False;
                                end;
                              UnselectedPtsCalc0(fst_lst_sln_obj_pts,sln_pts,pvt,pvt_origin);
                            end;
                          ChangeSelectionMode(CB_Select_Points_Selection_Mode.ItemIndex);
                        end;
                      Exit;
                    end

                  {Unselect Pivot}
                  else
                    begin
                      if exp0 then
                        srf_var.EventGroupsCalc(calc_arr,[16,27,30,31,32]);
                      sel_var.sel_pts:=True;
                      ChangeSelectionMode(CB_Select_Points_Selection_Mode.ItemIndex);
                    end;

                  L_Object_Info.Visible:=(not move_pvt) and show_obj_info;

                end;

          end;

      end;

    (mbMiddle):
      begin

        {Minimize Circle Selection}
        if down_select_points_ptr^ then
          with sel_var,srf_var,crc_sel_var do
            begin
              LowerBmpToMainBmp;
              need_repaint:=True;
              MinimizeCircleSelection;
              CnvToCnv(srf_bmp_rct,Canvas,srf_bmp.Canvas,SRCCOPY);
              need_repaint:=False;
            end;

      end;

    (mbRight):
      begin

        {Pivot To Point Begin}
        with srf_var,sln_var,pvt_var do
          if down_select_points_ptr^ and
             move_pvt_to_pt_button   and
             ((pvt.x-x)*(pvt.x-x)+
              (pvt.y-y)*(pvt.y-y)<=crc_sel_var.crc_rad_sqr) then
            begin
              pvt_to_pt:=not pvt_to_pt;
              case CB_Select_Points_Selection_Mode.ItemIndex of
                0,1:
                  with crc_sel_var do
                    begin
                      draw_crc_sel:=not pvt_to_pt;
                      crc_sel_rct :=Default(TRect);
                    end;
                2:rct_sel_var.rct_sel:=Default(TRect);
              end;
              ArrClear(dup_pts_arr,inn_wnd_rct,srf_bmp.width);
              AddSplineDupPtsAll(0,sln_obj_cnt-1);
              pvt_prev.x:=Trunc(pvt.x);
              pvt_prev.y:=Trunc(pvt.y);
              L_Object_Info.Visible:=not pvt_to_pt;
              if I_Visibility_Panel.Visible then
                 I_Visibility_Panel.Visible:=False;
            end;

      end;

  end;

end; {$endregion}
procedure TF_MainForm.FormMouseUp       (sender:TObject; button:TMouseButton; shift:TShiftState; x,y:integer);     {$region -fold}
begin

  {if down_play_anim_ptr^ then
    begin
      ////
      Exit;
    end;}

  {Brush------------------} {$region -fold}
  draw_brush:=False; {$endregion}

  {Spray------------------} {$region -fold}
  draw_spray:=False; {$endregion}

  {Add Spline-------------} {$region -fold}
  if show_spline                   and
     down_spline_ptr^              and
    ((CB_Spline_Mode.ItemIndex=0)  or
     (CB_Spline_Mode.ItemIndex=2)) and
     (CB_Spline_Type.ItemIndex=0)  and
     add_spline_calc               then
    with sln_var do
      begin
        VisibilityChange(srf_var.inner_window_ui_visible);
        srf_var.EventGroupsCalc(calc_arr,[12,30,31,33]);
        draw_spline:=False;
        SpeedButtonRepaint;
      end; {$endregion}

  {Finish Points Selection} {$region -fold}
  if show_spline             and
     down_select_points_ptr^ and
     sel_var.sel_pts         and
     (not pvt_var.move_pvt)  then
    with srf_var,sln_var,sel_var,crc_sel_var,pvt_var do
      begin
        EventGroupsCalc(calc_arr,[6,20,30]);
        pvt_draw_sel_eds_off:=pvt;
        sel_pts             :=False;
        need_align_pivot_p2 :=True;
        SpeedButtonRepaint;
      end; {$endregion}

end; {$endregion}
procedure TF_MainForm.FormDblClick      (sender:TObject);                                                          {$region -fold}
begin

  {Add Spline} {$region -fold}
  if show_spline and down_spline_ptr^ and
     (CB_Spline_Mode.ItemIndex=1)     and
     (CB_Spline_Type.ItemIndex=0)    then
    with srf_var,sln_var do
      begin
        Dec(sln_pts_cnt);
        Dec(sln_pts_cnt_add);
        EventGroupsCalc(calc_arr,[12,16,30,33]);
        draw_spline:=False;
        VisibilityChange(show_visibility_panel);
      end; {$endregion}

end; {$endregion}
procedure TF_MainForm.FormPaint         (sender:TObject);                                                          {$region -fold}
begin
  with srf_var do
    if (not need_repaint) then
          CnvToCnv(srf_bmp_rct,      // Main Layer Bitmap Drawing
                   F_MainForm.Canvas,// .....
                   srf_bmp.Canvas,   // .....
                   SRCCOPY);         // .....
end; {$endregion}
procedure TF_MainForm.FormMouseWheelDown(sender:TObject; shift:TShiftState; mousePos:TPoint; var handled:boolean); {$region -fold}
begin
  if drawing_area_enter_calc then
    begin
      {if down_play_anim_ptr^ then
        begin
          ////
          Exit;
        end;}
      if (Shift<>[ssCtrl]) then
        begin
          with srf_var,rgr_var,sgr_var,crc_sel_var do
            begin
              if (scl_dif<-17{20}) then
                Exit;
              Dec(scl_dif);
              scl_dir:=sdDown;
              if down_select_points_ptr^ then
                crc_sel_rct:=Default(TRect);
              with srf_var do
                if down_play_anim_ptr^ then
                  SetBkgnd
                  (
                    srf_bmp_ptr,
                    srf_bmp.width,
                    srf_bmp.height,
                    inn_wnd_rct
                  );
              EventGroupsCalc(calc_arr,[8,9,18,19,23,24,29,30,31,32]);
            end;
        end
      else
        {Resize And Draw Circle Selection}
        if down_select_points_ptr^ then
          with sel_var,crc_sel_var,brs_sel_var do
            begin
              if (crc_rad<11) then
                Exit;
              crc_rad       -=10;
              crc_rad_sqr   :=crc_rad*crc_rad;
              resize_crc_sel:=False;
              draw_crc_sel  :=False;
              draw_brs_sel  :=False;
              case CB_Select_Points_Selection_Mode.ItemIndex of
                0,1:
                  with srf_var do
                    begin
                      need_repaint:=True;
                      LowerBmpToMainBmp;
                      ResizeCircleSelectionModeDraw;
                      AddCircleSelection;
                      CrtCircleSelection;
                      with crc_sel_rct do
                        begin
                         {CircleSelectionModeDraw(left+width >>1,
                                                  top +height>>1,
                                                  srf_var);}
                          FilSelPtsObj(left,top);
                        end;
                      CnvToCnv(srf_bmp_rct,Canvas,srf_bmp.Canvas,SRCCOPY);
                      need_repaint      :=False;
                      crc_rad_invalidate:=crc_rad;
                      draw_crc_sel      :=True;
                      resize_crc_sel    :=True;
                    end;
              end;
            end;
    end;
  SpeedButtonRepaint;
end; {$endregion}
procedure TF_MainForm.FormMouseWheelUp  (sender:TObject; shift:TShiftState; mousePos:TPoint; var handled:boolean); {$region -fold}
var
  max_sqr,min_sqr: integer;
begin
  if drawing_area_enter_calc then
    begin
      {if down_play_anim_ptr^ then
        begin
          ////
          Exit;
        end;}
      if (Shift<>[ssCtrl]) then
        begin
          with srf_var,tex_var,rgr_var,sgr_var,crc_sel_var do
            begin
              if (Trunc(Math.Max(tex_bmp_rct_pts[1].x-tex_bmp_rct_pts[0].x,tex_bmp_rct_pts[1].y-tex_bmp_rct_pts[0].y)/50)>Math.Min(inn_wnd_rct.width,inn_wnd_rct.height)) then
                Exit;
              Inc(scl_dif);
              scl_dir:=sdUp;
              if down_select_points_ptr^ then
                crc_sel_rct:=Default(TRect);
              with srf_var do
                if down_play_anim_ptr^ then
                  SetBkgnd
                  (
                    srf_bmp_ptr,
                    srf_bmp.width,
                    srf_bmp.height,
                    inn_wnd_rct
                  );
              EventGroupsCalc(calc_arr,[8,9,18,19,23,24,29,30,31,32]);
            end;
        end
      else
        {Resize And Draw Circle Selection}
        if down_select_points_ptr^ then
          with sel_var,srf_var,crc_sel_var,brs_sel_var do
            begin
              {max_sqr:=Max(srf_bmp.width,srf_bmp.height);
              max_sqr*=max_sqr;
              min_sqr:=Min(srf_bmp.width,srf_bmp.height);
              min_sqr*=min_sqr;
              if ((crc_rad*crc_rad)<<2+0>=min_sqr+max_sqr) or
                 ( crc_rad         <<1+3>=000000000004096) then
                Exit;}
              if (crc_rad<<1+20>=Min(inn_wnd_rct.width,inn_wnd_rct.height)) or
                 (crc_rad<<1+20>=000000000000000000000000000004096) then
                Exit;
              crc_rad       +=10;
              crc_rad_sqr   :=crc_rad*crc_rad;
              resize_crc_sel:=False;
              draw_crc_sel  :=False;
              draw_brs_sel  :=False;
              case CB_Select_Points_Selection_Mode.ItemIndex of
                0,1:
                  begin
                    need_repaint:=True;
                    LowerBmpToMainBmp;
                    ResizeCircleSelectionModeDraw;
                    AddCircleSelection;
                    CrtCircleSelection;
                    with crc_sel_rct do
                      begin
                       {CircleSelectionModeDraw(left+width >>1,
                                                top +height>>1,
                                                srf_var);}
                        FilSelPtsObj(left,top);
                      end;
                    CnvToCnv(srf_bmp_rct,Canvas,srf_bmp.Canvas,SRCCOPY);
                    need_repaint      :=False;
                    crc_rad_invalidate:=crc_rad;
                    draw_crc_sel      :=True;
                    resize_crc_sel    :=True;
                  end;
              end;
            end;
    end;
  SpeedButtonRepaint;
end; {$endregion}
procedure TF_MainForm.FormKeyPress      (sender:TObject; var key:char);                                            {$region -fold}

  procedure ButtonKeyPress(sp_btn:TSpeedButton; btn_pnl1,btn_pnl2,btn_pnl3:TPanel; down_btn_ptr:PByteBool; b:byte; cur1:integer; cur2:integer=crDefault); {$region -fold}
   begin
     sp_btn.Down:=not sp_btn.Down;
     case b of
       0:
         begin
           DrawingPanelsSetVisibility1(down_btn_ptr,btn_pnl1,btn_pnl2,prev_panel_draw,curr_panel_draw);
           DrawingPanelsSetVisibility2;
         end;
       1:
         begin
           DrawingPanelsSetVisibility1(down_btn_ptr,btn_pnl1,btn_pnl2,prev_panel_animk,curr_panel_animk);
         //DrawingPanelsSetVisibility2;
         end;
     end;
     btn_pnl3.Repaint;
     InvalidateInnerWindow;
     if down_btn_ptr^ then
       Screen.Cursor:=cur1
     else
       Screen.Cursor:=cur2;
   end; {$endregion}

begin

   if down_play_anim_ptr^ then
     begin
       if (key=#32{'space'}) then
         time_interval:=-1;
       Exit;
     end;

     // button 'Text':
     if (key=Char(key_arr[04]{#49})) or (key=Char(key_alt_arr[04]{' '})) then
       ButtonKeyPress(SB_Text                 ,P_Text                 ,P_Draw_Custom_Panel,P_Drawing_Buttons,down_text_ptr                 ,0,000001);
     // button 'Brush':
     if (key=Char(key_arr[05]{#50})) or (key=Char(key_alt_arr[05]{' '})) then
       ButtonKeyPress(SB_Brush                ,P_Brush                ,P_Draw_Custom_Panel,P_Drawing_Buttons,down_brush_ptr                ,0,000002);
     // button 'Spray':
     if (key=Char(key_arr[06]{#51})) or (key=Char(key_alt_arr[06]{' '})) then
       ButtonKeyPress(SB_Spray                ,P_Spray                ,P_Draw_Custom_Panel,P_Drawing_Buttons,down_spray_ptr                ,0,000003);
     // button 'Spline':
     if (key=Char(key_arr[07]{#52})) or (key=Char(key_alt_arr[07]{'q'})) then
       ButtonKeyPress(SB_Spline               ,P_Spline               ,P_Draw_Custom_Panel,P_Drawing_Buttons,down_spline_ptr               ,0,000004);
     // button 'Select Points':
     if (key=Char(key_arr[08]{#53})) or (key=Char(key_alt_arr[08]{'e'})) then
       ButtonKeyPress(SB_Select_Points        ,P_Select_Points        ,P_Draw_Custom_Panel,P_Drawing_Buttons,down_select_points_ptr        ,0,crNone);
     // button 'Select Texture Region':
     if (key=Char(key_arr[09]{#54})) or (key=Char(key_alt_arr[09]{' '})) then
       ButtonKeyPress(SB_Select_Texture_Region,P_Select_Texture_Region,P_Draw_Custom_Panel,P_Drawing_Buttons,down_select_texture_region_ptr,0,000006);
     // button 'Regular Grid':
     if (key=Char(key_arr[10]{#54})) or (key=Char(key_alt_arr[10]{' '})) then
       ButtonKeyPress(SB_RGrid                ,P_RGrid                ,P_Draw_Custom_Panel,P_Drawing_Buttons,down_rgrid_ptr                ,0,000007);
     // button 'Snap Grid':
     if (key=Char(key_arr[11]{#54})) or (key=Char(key_alt_arr[11]{' '})) then
       ButtonKeyPress(SB_SGrid                ,P_SGrid                ,P_Draw_Custom_Panel,P_Drawing_Buttons,down_sgrid_ptr                ,0,000008);
     // change pivot mode:
     if (key=#32{'space'}) then
       if down_select_points_ptr^ then
         begin
           if (sel_var.sel_pts_cnt>0) then
             with pvt_var do
               case pvt_mode of
                 (pmPivotMove  ): pvt_mode:=(pmPivotScale );
                 (pmPivotScale ): pvt_mode:=(pmPivotRotate);
                 (pmPivotRotate): pvt_mode:=(pmPivotMove  );
               end
           else
             begin
               if (CB_Select_Points_Selection_Mode.ItemIndex=CB_Select_Points_Selection_Mode.Items.Count-1) then
                 CB_Select_Points_Selection_Mode.ItemIndex:=0
               else
                 CB_Select_Points_Selection_Mode.ItemIndex:=CB_Select_Points_Selection_Mode.ItemIndex+1;
               sel_var.ChangeSelectionMode(CB_Select_Points_Selection_Mode.ItemIndex);
             end;
           InvalidateInnerWindow;
         end;

end; {$endregion}
procedure TF_MainForm.FormKeyDown       (sender:TObject; var key:word; shift:TShiftState);                         {$region -fold}
begin

  is_active:=True;
  case Key of
    65: key_down:=65;
    68: key_down:=68;
    87: key_down:=87;
    83: key_down:=83;
  end;
  key_down_arr[0]:=key_down_arr[1];
  key_down_arr[1]:=key_down_arr[2];
  key_down_arr[2]:=key_down;

  with srf_var,sln_var,tex_var,sel_var,pvt_var do
    begin

      {Check Exit-----} {$region -fold}
      if (inn_wnd_rct.width <=0) or
         (inn_wnd_rct.height<=0) then
        Exit; {$endregion}

      if T_Menu.Enabled then
        begin
          case Key of
            65,68,87,83: PlaySound(PChar(SELECT_ITEM),0,SND_ASYNC);
          end;
          case Key of
            {'Enter'}13:
              if (menu_img_arr_cnt=0) then
                begin
                  mciSendString(PChar('stop "'+MENU_THEME+'"'),nil,0,0);
                  T_Menu.Enabled:=False;
                  T_Game.Enabled:=True;
                end;
            {'a'}65:
              begin

              end;
            {'d'}68:
              begin

              end;
            {'w'}87:
              begin
                menu_img_arr_cnt-=1;
                if (menu_img_arr_cnt=-1) then
                  menu_img_arr_cnt:=2;
              end;
            {'s'}83:
              begin
                menu_img_arr_cnt+=1;
                if (menu_img_arr_cnt=3) then
                  menu_img_arr_cnt:=0;
              end;
          end;
          Exit;
        end;

      if T_Game.Enabled or T_Game_Loop.Enabled then
        begin
          case Key of
            {'a'}65:
              dir_a:=True;
            {'d'}68:
              dir_d:=True;
            {'w'}87:
              dir_w:=True;
            {'s'}83:
              dir_s:=True;
          end;
          Exit;
        end;

      if down_play_anim_ptr^ then
        Exit;

      case Key of
        65,68,87,83:
          begin
            draw_spline:=False;
            sel_pts    :=False;
          end;
      end;

      case Key of

        {   }{'Alt'}18:
        if need_align_pivot_p2 then
          begin
            ArrClear(dup_pts_arr,inn_wnd_rct,srf_bmp.width);
            AddSplineDupPtsAll(0,sln_obj_cnt-1);
            pvt_prev.x         :=Trunc(pvt.x);
            pvt_prev.y         :=Trunc(pvt.y);
            need_align_pivot_p2:=False;
          end;

        {VK_LEFT,VK_RIGHT,VK_UP,VK_DOWN: Key:=0;}
        {#9  } VK_TAB : {$region -fold}
          begin
            VisibilityChange(True);
            srf_var.inner_window_ui_visible:=True;
            show_visibility_panel          :=True;
          end; {$endregion}

        {#97 }{'a'} 65: {$region -fold}
          begin
            SetBkgnd
            (
              low_bmp_ptr,
              low_bmp.width,
              low_bmp.height,
              inn_wnd_rct
            );
            MovLeft;
            FilLeft
            (
              low_bmp_ptr,
              low_bmp.width,
              low_bmp.height,
              inn_wnd_rct
            );
          end; {$endregion}

        {#100}{'d'} 68: {$region -fold}
          begin
            SetBkgnd
            (
              low_bmp_ptr,
              low_bmp.width,
              low_bmp.height,
              inn_wnd_rct
            );
            MovRight;
            FilRight
            (
              low_bmp_ptr,
              low_bmp.width,
              low_bmp.height,
              inn_wnd_rct
            );
          end; {$endregion}

        {#119}{'w'} 87: {$region -fold}
          begin
            SetBkgnd
            (
              low_bmp_ptr,
              low_bmp.width,
              low_bmp.height,
              inn_wnd_rct
            );
            MovUp;
            FilUp
            (
              low_bmp_ptr,
              low_bmp.width,
              low_bmp.height,
              inn_wnd_rct
            );
          end; {$endregion}

        {#115}{'s'} 83: {$region -fold}
          begin
            SetBkgnd
            (
              low_bmp_ptr,
              low_bmp.width,
              low_bmp.height,
              inn_wnd_rct
            );
            MovDown;
            FilDown
            (
              low_bmp_ptr,
              low_bmp.width,
              low_bmp.height,
              inn_wnd_rct
            );
          end; {$endregion}

      end;

      case Key of

        65,68,87,83   : {$region -fold}
          with srf_var,sgr_var,sel_var,pvt_var do
            begin
              {Background Drawing1} {$region -fold}
              LowerBmpToMainBmp; {$endregion}
              {Hide Panels--------} {$region -fold}
              VisibilityChange(False);
              {$endregion}
              {Pivot Drawing------} {$region -fold}
              if (sel_pts_cnt>0) then
                begin
                  PivotDraw(srf_var.world_axis_shift);
                  IsPivotOutOfInnerWindow(pvt_axis_rect,pvt);
                end; {$endregion}
              {World Axis Drawing-} {$region -fold}
              if world_axis_draw then
                WorldAxisDraw; {$endregion}
              {Reset Some Var.----} {$region -fold}
              srf_bmp.Canvas.CopyMode:=cmSrcCopy;
              crc_sel_var.crc_sel_rct:=Default(TRect); {$endregion}
              {Post-Process-------} {$region -fold}
              {PPBlur(srf_bmp_ptr,
                     inn_wnd_rct,
                     srf_bmp.width);} {$endregion}
              {Background Drawing2} {$region -fold}
              CnvToCnv
              (
                srf_bmp_rct,
                Canvas,
                srf_bmp.Canvas,
                SRCCOPY
              ); {$endregion}
            end; {$endregion}

      end;

    end;

end; {$endregion}
procedure TF_MainForm.FormKeyUp         (sender:TObject; var key:word; shift:TShiftState);                         {$region -fold}
begin

  is_active       :=False;
  downtime_counter:=0;
  key_down        :=0;
  key_down_arr[0] :=key_down_arr[1];
  key_down_arr[1] :=key_down_arr[2];
  key_down_arr[2] :=key_down;

  if T_Game.Enabled or T_Game_Loop.Enabled then
    begin
      case Key of
        {'a'}65:
          srf_var.dir_a:=False;
        {'d'}68:
          srf_var.dir_d:=False;
        {'w'}87:
          srf_var.dir_w:=False;
        {'s'}83:
          srf_var.dir_s:=False;
      end;
      //Exit;
    end;

  {if T_Menu.Enabled then
    Exit;}

  {if T_Game.Enabled then
    Exit;}

  {if down_play_anim_ptr^ then
    Exit;}

  case Key of

    {VK_LEFT,VK_RIGHT,VK_UP,VK_DOWN: Key:=0;}
    {#9} VK_TAB:
      begin
        VisibilityChange(False);
        srf_var.inner_window_ui_visible:=False;
        show_visibility_panel          :=False;
        F_Hot_Keys.Visible             :=False;
        InvalidateInnerWindow;
        crc_sel_var.crc_sel_rct:=Default(TRect);
      end;

    65,68,87,83:
      begin
        if (not down_play_anim_ptr^) then
          begin
            VisibilityChange(srf_var.inner_window_ui_visible);
            show_visibility_panel:=True;
          end;
        with srf_var do
          SetBkgnd
          (
            srf_bmp_ptr,
            srf_bmp.width,
            srf_bmp.height,
            inn_wnd_rct
          );
        srf_var.EventGroupsCalc(calc_arr,[6,9,18,20,23,30,31,32]);
        with srf_var do
          if down_play_anim_ptr^ then
            SetBkgnd
            (
              low_bmp_ptr,
              low_bmp.width,
              low_bmp.height,
              inn_wnd_rct
            )
          {else
            SetBkgnd
            (
              srf_bmp_ptr,
              srf_bmp.width,
              srf_bmp.height,
              inn_wnd_rct
            )};
      end;

  end;

  SpeedButtonRepaint;

end; {$endregion}
procedure TF_MainForm.FormMouseEnter    (sender:TObject);                                                          {$region -fold}
begin
  {Add Actor} {$region -fold}
  //if down_add_actor_ptr^ then
    with srf_var,fast_actor_set_var.d_icon do
      begin
        SetBkgnd (srf_bmp_ptr,
                  srf_bmp.width,
                  srf_bmp.height);
        SetClpRct(inn_wnd_rct);
      end; {$endregion}
  {if anim_play then
    OnMouseMove:=Nil;}
  drawing_area_enter_calc:=True;
  DefocusControl(ActiveControl,True);
  KeysEnable;
  {Play Anim} {$region -fold}
  if down_play_anim_ptr^ then
    begin
      Screen.Cursor:=crNone;
      Exit;
    end
  else
    Screen.Cursor:=crDefault; {$endregion}
  if down_text_ptr^ then
    Screen.Cursor:=1;
  if down_brush_ptr^ then
    Screen.Cursor:=2;
  if down_spray_ptr^ then
    Screen.Cursor:=3;
  if down_spline_ptr^ then
    Screen.Cursor:=4;
  if down_select_points_ptr^ then
    begin
      Screen.Cursor:=crNone;
      if (CB_Select_Points_Selection_Mode.ItemIndex=1) then
        brs_sel_var.draw_brs_sel:=True;
      crc_sel_var.crc_sel_rct   :=Default(TRect);
      rct_sel_var.rct_sel       :=Default(TRect);
    end;
  if down_select_texture_region_ptr^ then
    Screen.Cursor:=6;
  if down_rgrid_ptr^ then
    Screen.Cursor:=7;
  if down_sgrid_ptr^ then
    Screen.Cursor:=8;
end; {$endregion}
procedure TF_MainForm.FormMouseLeave    (sender:TObject);                                                          {$region -fold}
begin
  drawing_area_enter_calc:=False;
  if down_select_points_ptr^ then
    case CB_Select_Points_Selection_Mode.ItemIndex of
      0,1:
        with crc_sel_var,brs_sel_var do
          begin
            resize_crc_sel:=False;
            draw_brs_sel  :=False;
            crc_sel_rct   :=Default(TRect);
            InvalidateInnerWindow;
          end;
    end;
  Screen.Cursor:=crDefault;
end; {$endregion}
procedure TF_MainForm.FormCreate        (sender:TObject);                                                          {$region -fold}
var
  color_info      : TColorInfo;
  world_axis_shift: TPtPos;
  i               : integer;
begin

  {Scene Tree-----------} {$region -fold}
  obj_var:=TSceneTree.Create;
  if (srf_var<>Nil) then
    world_axis_shift:=srf_var.world_axis_shift
  else
    world_axis_shift:=Default(TPtPos);
  obj_var.Add(kooEmpty,world_axis_shift);
  CreateNode('','',True);
  ObjIndsCalc;
  ScTIndsCalc; {$endregion}

  {Post-Process Init.---} {$region -fold}
  PPDec2ProcInit;
  ArrFillProcInit;
  PPBlurProcInit; {$endregion}

  {General--------------} {$region -fold}

    {Window Splitters} {$region -fold}
    S_Splitter0.height       :=splitter_thickness;
    S_Splitter1.left         :=0;
    S_Splitter1.width        :=splitter_thickness;
    S_Splitter2.height       :=splitter_thickness;
    S_Splitter3.left         :=F_MainForm.width;
    S_Splitter3.width        :=splitter_thickness;
    S_Splitter4.height       :=splitter_thickness;
    P_Splitter5.height       :=splitter_thickness;
    S_Splitter6.height       :=splitter_thickness;
    S_Splitter7.top          :=(F_MainForm.height+S_Splitter6.top)>>1;
    S_Splitter7.height       :=splitter_thickness;
    splitters_arr[0]         :=Unaligned(@S_Splitter0.top );
    splitters_arr[1]         :=Unaligned(@S_Splitter1.left);
    splitters_arr[2]         :=Unaligned(@S_Splitter2.top );
    splitters_arr[3]         :=Unaligned(@S_Splitter3.left);
    splitters_arr[4]         :=Unaligned(@S_Splitter4.top );
    splitters_arr[5]         :=Unaligned(@P_Splitter5.top );
    splitters_arr[6]         :=Unaligned(@S_Splitter6.top );
    splitters_arr[7]         :=Unaligned(@S_Splitter7.top );
    treeview_splitter_shift  :=S_TreeView_Splitter.Left-S_Splitter3.left; {$endregion}

    {Misc. Settings--} {$region -fold}
    MaxSpriteWHRctInit(max_sprite_w_h_rct);
    AutoScale;
    bkg_pp_calc              :=False;
    show_spline_pts_b_rect_1 :=False;
    show_spline_pts_b_rect_2 :=False;
    show_selected_pts_b_rect :=False;
    Application.HintPause    :=250;
    Application.HintHidePause:=3000;
    for i:=0 to ComponentCount-1 do
      if (Components[i] is TWinControl) then
         (Components[i] as TWinControl).TabStop:=False;
    F_MainForm.Menu        :=Nil;
    //F_MainForm.Menu        :=MainMenu1;
    MouseMoveProcInit(P_Drawing_Buttons  ,@P_Drawing_ButtonsMouseMove   );
    MouseMoveProcInit(P_Animation_Buttons,@P_Animation_ButtonsMouseMove );
    ini_var:=TIniFile.Create(ExtractFilePath(ParamStr(0))+'settings.ini');
    TrayIcon1.Show; {$endregion}

    {Buttons:File----} {$region -fold}
    for i:=0 to SB_Image_List.ControlCount-1 do
      SB_Image_List.Controls[i].Anchors:=[akLeft,akTop,akRight,akBottom]; {$endregion}

    {Buttons:Draw----} {$region -fold}
    for i:=0 to SB_Drawing.ControlCount-1 do
      SB_Drawing.Controls[i].Anchors:=[akLeft,akTop,akRight,akBottom];
    prev_panel_draw                 :=P_Draw_Custom_Panel;
    curr_panel_draw                 :=P_Spline;
    P_Draw_Custom_Panel.Visible     :=False; {$endregion}

    {Buttons:AnimK---} {$region -fold}
    for i:=0 to SB_AnimK.ControlCount-1 do
      SB_AnimK.Controls[i].Anchors:=[akLeft,akTop,akRight,akBottom];
    prev_panel_animk              :=P_AnimK_Custom_Panel;
    curr_panel_animk              :=P_Map_Editor;
    P_AnimK_Custom_Panel.Visible  :=False; {$endregion}

  {$endregion}

  {Visibility Panel-----} {$region -fold}
  visibility_panel_picture                          :=Graphics.TBitmap.Create;
  visibility_panel_picture         .width           :=I_Visibility_Panel.width;
  visibility_panel_picture         .height          :=I_Visibility_Panel.height;
  I_Visibility_Panel.Picture.Bitmap.width           :=I_Visibility_Panel.width;
  I_Visibility_Panel.Picture.Bitmap.height          :=I_Visibility_Panel.height;
  I_Visibility_Panel.Picture.Bitmap.TransparentColor:=clBlack;
  SelectionBoundsRepaint; {$endregion}

  {Buttons Icons--------} {$region -fold}
  BB_Reset_Pivot        .Glyph:=SB_Move_Pivot_To_Point.Glyph;
  SB_Visibility_Show_All.Glyph:=SB_Spline_Points_Show .Glyph; {$endregion}

  {Main Layer-----------} {$region -fold}
  srf_var:=TSurf.Create(width,height); {$endregion}

  {Texture--------------} {$region -fold}
  tex_var:=TTex.Create(512,512); {$endregion}

  {Snap Grid------------} {$region -fold}
  sgr_var       :=TSGrid.Create(width,height);
  down_sgrid_ptr:=Unaligned(@SB_SGrid.Down); {$endregion}

  {Grid-----------------} {$region -fold}
  rgr_var             :=TRGrid.Create(width,height);
  SB_RGrid_Color.Color:=rgr_var.rgrid_color;
  down_rgrid_ptr      :=Unaligned(@SB_RGrid.Down); {$endregion}

  {Text-----------------} {$region -fold}
  down_text_ptr:=Unaligned(@SB_Text.Down); {$endregion}

  {Brush----------------} {$region -fold}
  CB_Brush_Mode.ItemIndex:=00;
  SE_Brush_Radius.Value  :=10;
  SE_Brush_Hardness.Value:=10;
  down_brush_ptr         :=Unaligned(@SB_Brush.Down); {$endregion}

  {Spray----------------} {$region -fold}
  down_spray_ptr:=Unaligned(@SB_Spray.Down); {$endregion}

  {Spline---------------} {$region -fold}
  CB_Spline_Mode.ItemIndex:=0;
  SB_Spline     .Down     :=True;
  P_Spline      .Visible  :=True;
  down_spline_ptr         :=Unaligned(@SB_Spline.Down);
  sln_var                 :=TCurve.Create
  (
    width,
    height,
    srf_var.srf_bmp_ptr,
    srf_var.srf_bmp.width,
    srf_var.srf_bmp.height
  );
  SplinesTemplatesNamesInit(sln_var); {$endregion}

  {Colliders------------} {$region -fold}
  show_collider:=True; {$endregion}

  {Selected Points------} {$region -fold}
  sel_var               :=TSelPts.Create
  (
    width,
    height,
    srf_var.srf_bmp_ptr,
    srf_var.srf_bmp.width,
    srf_var.srf_bmp.height,
    srf_var.inn_wnd_rct
  );
  down_select_points_ptr:=Unaligned(@SB_Select_Points.Down); {$endregion}

  {Select Texture Region} {$region -fold}
  down_select_texture_region_ptr:=Unaligned(@SB_Select_Texture_Region.Down); {$endregion}

  {UV-------------------} {$region -fold}
  uv_var:=TUV.Create(width,height); {$endregion}

  {Intersection Graph---} {$region -fold}
  isg_var:=TISGraph.Create(width,height); {$endregion}

  {Pivot----------------} {$region -fold}
  pvt_var:=TPivot.Create(25,25); {$endregion}

  {Circle Selection-----} {$region -fold}
  crc_sel_var:=TCircSel.Create; {$endregion}

  {Brush Selection------} {$region -fold}
  brs_sel_var:=TBrushSel.Create; {$endregion}

  {Rectangle Selection--} {$region -fold}
  rct_sel_var:=TRectSel.Create; {$endregion}

  {World Axis-----------} {$region -fold}
  WorldAxisCreate; {$endregion}

  {Play Animation-------} {$region -fold}
  down_play_anim_ptr:=Unaligned(@SB_Play_Anim.Down); {$endregion}

  {Map Editor-----------} {$region -fold}
  tlm_var              :=TTlMap.Create;
  SB_Map_Editor.Down   :=True;
  P_Map_Editor .Visible:=True;
  down_map_editor_ptr  :=Unaligned(@SB_Map_Editor.Down); {$endregion}

  {Add Actor------------} {$region -fold}
  with srf_var do
    fast_actor_set_var:=TFastActorSet.Create(srf_bmp_ptr,
                                             srf_bmp.width,
                                             srf_bmp.height,
                                             inn_wnd_rct,
                                             max_sprite_w_h_rct,
                                             Application.Location+DEFAULT_ACTOR_ICON,
                                             @IL_Add_Actor_Default_Icon.GetBitmap);
  img_lst_bmp:=CrtTBmpInst(I_Frame_List.width,
                           I_Frame_List.height,
                           img_lst_bmp_ptr);
  SetColorInfo($00957787,color_info);
  PPFloodFill(img_lst_bmp_ptr,
              PtBounds(0,0,img_lst_bmp.Width,img_lst_bmp.height),
              img_lst_bmp.Width,
              color_info.pix_col);
  with img_lst_bmp do
    begin
      SetTextInfo   (Canvas);
      Canvas.TextOut(width >>1-80,
                     height>>1-16,
                     'Frame List is Empty');
    end;
  with img_lst_bmp.Canvas do
    begin
      Brush.Style:=bsClear;
      Pen.Mode   :=pmCopy;
      Pen.Color  :=clBlue;
    end;
  img_lst_bmp.Canvas.Rectangle(0,0,
                               img_lst_bmp.width,
                               img_lst_bmp.height);
  CnvToCnv(PtBounds(0,0,
                    img_lst_bmp.width,
                    img_lst_bmp.height),
           I_Frame_List.Canvas,
           img_lst_bmp .Canvas,
           SRCCOPY);
  add_actor_var     :=TSurfInst.Create(I_Frame_List.width,
                                       I_Frame_List.height);
  down_add_actor_ptr:=@SB_Add_Actor.Down; {$endregion}

  {TimeLine-------------} {$region -fold}
  TimeLineButtonsCreate; {$endregion}

  {Cursors--------------} {$region -fold}
  CursorsCreate;
  // 'Text' button cursor init.:
  CursorInit(1,0,Application.Location+TEXT_BUTTON_ICON                 ,@IL_Drawing_Buttons.GetBitmap);
  // 'Brush' button cursor init.:
  CursorInit(2,6,Application.Location+BRUSH_CURSOR_ICON                ,@IL_Drawing_Buttons.GetBitmap);
  // 'Spray' button cursor init.:
  CursorInit(3,2,Application.Location+SPRAY_BUTTON_ICON                ,@IL_Drawing_Buttons.GetBitmap);
  // 'Spline' button cursor init.:
  CursorInit(4,3,Application.Location+SPLINE_BUTTON_ICON               ,@IL_Drawing_Buttons.GetBitmap);
  // 'Select Points' button cursor init.:
  CursorInit(5,4,Application.Location+SELECT_POINTS_BUTTON_ICON        ,@IL_Drawing_Buttons.GetBitmap);
  // 'Select Texture Region' button cursor init.:
  CursorInit(6,5,Application.Location+SELECT_TEXTURE_REGION_BUTTON_ICON,@IL_Drawing_Buttons.GetBitmap);
  // 'Select Texture Region' button cursor init.:
  CursorInit(7,7,Application.Location+REGULAR_GRID_BUTTON_ICON         ,@IL_Drawing_Buttons.GetBitmap);
  // 'Select Texture Region' button cursor init.:
  CursorInit(8,8,Application.Location+SNAP_GRID_BUTTON_ICON            ,@IL_Drawing_Buttons.GetBitmap); {$endregion}

  {Physics--------------} {$region -fold}
  fast_physics_var:=TCollider.Create(width,height);
  fast_fluid_var  :=TFluid   .Create(0,0); {$endregion}

  {Main Calculations----} {$region -fold}
  tex_var.AlignPictureToCenter;
  srf_var.EventGroupsCalc(calc_arr,[0,1,2,4,8,9]); {$endregion}

  with srf_var do
    begin
      SetLength(useless_fld_arr_,srf_bmp.width*srf_bmp.height);
      ArrClear (useless_fld_arr_,inn_wnd_rct,  srf_bmp.width );
    end;
  SetLength(useless_arr_,1);
  useless_arr_[0]:=1;

  SB_Unfold_Image_WindowClick(F_MainForm);
  S_Splitter2.top:=540;

  {Game-----------------} {$region -fold}
  with srf_var do
    logo1_img:=TFastImage.Create(srf_bmp_ptr,
                                 srf_bmp.width,
                                 srf_bmp.height,
                                 inn_wnd_rct,
                                 max_sprite_w_h_rct,
                                 Application.Location+LOGO1);
  with logo1_img do
    begin
      col_trans_arr[02]:=255;
      nt_pix_cng_type  :=001;
      pt_pix_cng_type  :=001;
      nt_pix_cfx_type  :=002;
      pt_pix_cfx_type  :=002;
    end;

  with srf_var do
    logo2_img:=TFastImage.Create(srf_bmp_ptr,
                                 srf_bmp.width,
                                 srf_bmp.height,
                                 inn_wnd_rct,
                                 max_sprite_w_h_rct,
                                 Application.Location+LOGO2);
  with logo2_img do
    begin
      col_trans_arr[02]:=255;
      nt_pix_cng_type  :=001;
      pt_pix_cng_type  :=001;
      nt_pix_cfx_type  :=002;
      pt_pix_cfx_type  :=002;
    end;

  with srf_var do
    start_game_img:=TFastImage.Create(srf_bmp_ptr,
                                      srf_bmp.width,
                                      srf_bmp.height,
                                      inn_wnd_rct,
                                      max_sprite_w_h_rct,
                                      Application.Location+START_GAME);
  with start_game_img do
    begin
      col_trans_arr[02]:=000;
      nt_pix_cng_type  :=001;
      pt_pix_cng_type  :=001;
      nt_pix_cfx_type  :=002;
      pt_pix_cfx_type  :=002;
    end;

  with srf_var do
    settings_img:=TFastImage.Create(srf_bmp_ptr,
                                    srf_bmp.width,
                                    srf_bmp.height,
                                    inn_wnd_rct,
                                    max_sprite_w_h_rct,
                                    Application.Location+SETTINGS);
  with settings_img do
    begin
      col_trans_arr[02]:=000;
      nt_pix_cng_type  :=001;
      pt_pix_cng_type  :=001;
      nt_pix_cfx_type  :=002;
      pt_pix_cfx_type  :=002;
    end;

  with srf_var do
    save_and_exit_img:=TFastImage.Create(srf_bmp_ptr,
                                         srf_bmp.width,
                                         srf_bmp.height,
                                         inn_wnd_rct,
                                         max_sprite_w_h_rct,
                                         Application.Location+SAVE_AND_EXIT);
  with save_and_exit_img do
    begin
      col_trans_arr[02]:=000;
      nt_pix_cng_type  :=001;
      pt_pix_cng_type  :=001;
      nt_pix_cfx_type  :=002;
      pt_pix_cfx_type  :=002;
    end;

  with srf_var do
    selection_border_img:=TFastImage.Create(srf_bmp_ptr,
                                            srf_bmp.width,
                                            srf_bmp.height,
                                            inn_wnd_rct,
                                            max_sprite_w_h_rct,
                                            Application.Location+SELECTION_BORDER);
  with selection_border_img do
    begin
      col_trans_arr[02]:=200;
      nt_pix_cng_type  :=001;
      pt_pix_cng_type  :=001;
      nt_pix_cfx_type  :=002;
      pt_pix_cfx_type  :=002;
    end;

  with srf_var do
    military_head_img:=TFastImage.Create(srf_bmp_ptr,
                                            srf_bmp.width,
                                            srf_bmp.height,
                                            inn_wnd_rct,
                                            max_sprite_w_h_rct,
                                            Application.Location+MILITARY_HEAD);
  with military_head_img do
    begin
      col_trans_arr[02]:=000;
      nt_pix_cng_type  :=001;
      pt_pix_cng_type  :=001;
      nt_pix_cfx_type  :=002;
      pt_pix_cfx_type  :=002;
    end; {$endregion}

end; {$endregion}
procedure TF_MainForm.FormActivate      (sender:TObject);                                                          {$region -fold}
var
  i: integer;
begin
  {AlphaBlend:=True;
  for i:=0 to 63 do
    begin
      AlphaBlendValue:=i*4;
      {$ifdef Windows}
      Sleep(2);
      {$else}
      USleep(1000000);
      {$endif}
    end;
  AlphaBlend:=False;}
  OnActivate:=Nil;             // Блокирует повторый вызов события
  {OnActivate:=@FormActivate;} // Возобновляет повторный вызов события
  {F_3D_Viewer.Show;}
  {MI_Full_ScreenClick(F_MainForm);}
  fill_scene_calc        :=True;
  srf_var.world_axis_draw:=True;
  with srf_var,inn_wnd_rct do
    world_axis:=PtPos((left+right )>>1,
                      (top +bottom)>>1);
  SB_Original_Texture_SizeClick(Self);
  SB_Spline_Edges_ShowClick    (Self);
  SB_Spline_Points_ShowClick   (Self);
  S_TreeView_Splitter.left:=F_MainForm.width;

  {Hot Keys Panel-----} {$region -fold}
  F_Hot_Keys.Visible:=True;
  F_Hot_Keys.Left   :=F_MainForm.left+11;
  F_Hot_Keys.Top    :=F_MainForm.top +81; {$endregion}

  {OpenGL Window------} {$region -fold}
  OpenGLControl2.Visible:=False;
  OpenGLControl2.Enabled:=False; {$endregion}

  {Game Mode} {$region -fold}
  {SB_Unfold_Image_WindowClick  (Self);
  SB_Unfold_Image_WindowClick  (Self);
  SB_Original_Texture_SizeClick(Self);
  VisibilityChange             (False);
  S_Splitter0.height    :=splitter_thickness;
  S_Splitter1.left      :=0;
  S_Splitter1.width     :=splitter_thickness;
  S_Splitter2.height    :=splitter_thickness;
  S_Splitter3.left      :=F_MainForm.width;
  S_Splitter3.width     :=splitter_thickness;
  S_Splitter4.height    :=splitter_thickness;
  P_Splitter5.height    :=splitter_thickness;
  S_Splitter6.height    :=splitter_thickness;
  S_Splitter7.top       :=(F_MainForm.height+S_Splitter6.top)>>1;
  S_Splitter7.height    :=splitter_thickness;
  F_Hot_Keys.Visible    :=False;
  F_Hot_Keys.Enabled    :=False;
  Screen.Cursor         :=crNone;
  OnMouseEnter          :=Nil;
  down_play_anim_ptr^   :=True;
  {OpenGLControl2.Visible:=down_play_anim_ptr^;
  OpenGLControl2.Enabled:=down_play_anim_ptr^;}
  tlm_var.AddTileMap;
  with srf_var do
    begin
      // Get Target Render For OpenGL Output:
      GLBitmapToRect(texture_id,srf_bmp,down_play_anim_ptr^);
      //if down_play_anim_ptr^ then
      GetObject(srf_bmp.Handle,SizeOf(buffer),@buffer);
      if down_play_anim_ptr^ then
        SetBckgd
        (
          low_bmp_ptr,
          low_bmp.width,
          low_bmp.height,
          inn_wnd_rct
        )
      else
        SetBckgd
        (
          srf_bmp_ptr,
          srf_bmp.width,
          srf_bmp.height,
          inn_wnd_rct
        );
      SB_Play_AnimClick(Self);
      //T_Logo1.Enabled:=down_play_anim_ptr^; //T_Game_Loop.Enabled:=down_play_anim_ptr^;
    end;} {$endregion}

  {F_MainForm.Memo1.Lines.Text:={GetEnumName(TypeInfo(TKindOfObject),Ord(PNodeData(TV_Scene_Tree.Items[3].Data)^.obj^.koo));}
                               IntToStr(obj_var.obj_inds_arr[0]^.g_ind)+#13+
                               IntToStr(obj_var.obj_inds_arr[1]^.g_ind)+#13+
                               IntToStr(obj_var.obj_inds_arr[2]^.g_ind)+#13+
                               IntToStr(obj_var.obj_inds_arr[3]^.g_ind)+#13+
                               IntToStr(obj_var.obj_inds_arr[4]^.g_ind)};

end; {$endregion}
procedure TF_MainForm.FormDestroy       (sender:TObject);                                                          {$region -fold}
begin
  MainArraysDone;
end; {$endregion}
procedure TF_MainForm.FormDropFiles     (sender:TObject; const file_names:array of string);                        {$region -fold}
var
  file_name: string;
begin
  for file_name in file_names do
    try
      tex_var.loaded_picture.LoadFromFile(file_name);
    except
      on E: Exception do
        MessageDlg('Error','Error: '+E.Message,mtError,[mbOk],0);
    end;
  tex_var.LoadTexture;
end; {$endregion}
{$endregion}

// (Scene Tree) Иерархия обьектов:
{LI} {$region -fold}
procedure ObjIndsCalc;                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  with F_MainForm.TV_Scene_Tree do
    for i:=0 to Items.Count-1 do
      begin
        obj_var.obj_inds_arr[i]:=PNodeData(Items[i].Data)^.g_ind;
        obj_var.obj_arr[obj_var.obj_inds_arr[i]].t_ind:=i;
      end;
end; {$endregion}
procedure ScTIndsCalc;                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i : integer;
  i0: integer=-1;
  i1: integer=-1;
  i2: integer=-1;
  i3: integer=-1;
  i4: integer=-1;
  i5: integer=-1;
  i6: integer=-1;
  i7: integer=-1;
  i8: integer=-1;
  i9: integer=-1;

  procedure SetIndsSctArrVal(var obj_inds_sct_arr:TColorArr; var ind1:integer; constref ind2:integer); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
  begin
    Inc(ind1);
    obj_inds_sct_arr[ind1]:=ind2;
  end; {$endregion}

begin
  with F_MainForm.TV_Scene_Tree do
    for i:=0 to Items.Count-1 do
      with obj_var do
        case obj_arr[PNodeData(Items[i].Data)^.g_ind].koo of
          kooEmpty: SetIndsSctArrVal(empty_inds_sct_arr,i0,i);
          kooBkgnd: SetIndsSctArrVal(bkgnd_inds_sct_arr,i1,i);
          kooBkTex: SetIndsSctArrVal(bktex_inds_sct_arr,i2,i);
          kooRGrid: SetIndsSctArrVal(rgrid_inds_sct_arr,i3,i);
          kooSGrid: SetIndsSctArrVal(sgrid_inds_sct_arr,i4,i);
          kooGroup: SetIndsSctArrVal(group_inds_sct_arr,i5,i);
          kooTlMap: SetIndsSctArrVal(tlmap_inds_sct_arr,i6,i);
          kooActor: SetIndsSctArrVal(actor_inds_sct_arr,i7,i);
          kooPrtcl: SetIndsSctArrVal(prtcl_inds_sct_arr,i8,i);
          kooCurve: SetIndsSctArrVal(curve_inds_sct_arr,i9,i);
        end;
end; {$endregion}
procedure CreateNodeData(node_with_data:TTreeNode; g_ind:TColor);                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  node_data_pointer: PNodeData;
begin
  New(node_data_pointer);
  node_data_pointer^.g_ind:=g_ind;
  case obj_var.obj_arr[g_ind].koo of
    kooEmpty:
      begin

      end;
    kooBkgnd:
      begin
        //node_data_pointer^.bckgd_prop.bckgd_obj_ind:=bckgd_prop.bckgd_obj_ind;

      end;
    kooBkTex:
      begin
        //node_data_pointer^.bktex_prop.bktex_obj_ind:=bktex_prop.bktex_obj_ind;

      end;
    kooRGrid:
      begin
        //node_data_pointer^.rgrid_prop.rgrid_obj_ind:=rgrid_prop.rgrid_obj_ind;

      end;
    kooSGrid:
      begin
        //node_data_pointer^.sgrid_prop.sgrid_obj_ind:=sgrid_prop.sgrid_obj_ind;

      end;
    kooGroup:
      begin
        //node_data_pointer^.group_prop.group_obj_ind:=group_prop.group_obj_ind;

      end;
    kooTlMap:
      begin
        //node_data_pointer^.tlmap_prop.tlmap_obj_ind:=tlmap_prop.tlmap_obj_ind;

      end;
    kooActor:
      begin
        //node_data_pointer^.actor_prop.actor_obj_ind:=actor_prop.actor_obj_ind;

      end;
    kooPrtcl:
      begin
        //node_data_pointer^.prtcl_prop.prtcl_obj_ind:=prtcl_prop.prtcl_obj_ind;

      end;
    kooCurve:
      begin
        //node_data_pointer^.curve_prop.curve_obj_ind:=curve_prop.curve_obj_ind;
        node_with_data.ImageIndex                  :=3;
      end;
  end;
  node_with_data.Data:=PNodeData(node_data_pointer);
end; {$endregion}
procedure ClearNodeData (node_with_data:TTreeNode);                                  inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  if (node_with_data.data<>Nil) then
    Dispose(PNodeData(node_with_data.data));
end; {$endregion}
procedure DeleteSelectedNodes(TV:TTreeView);                                         inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  List: TList;
  i,j : integer;
  f   : boolean;

  function HasAsParent(node,PotentialParent:TTreeNode): boolean;
  begin
    node:=node.Parent;
    while(node<>Nil) and (node<>PotentialParent) do
      node:=node.Parent;
    Result:=node=PotentialParent;
  end;

begin
  List:=TList.Create;
  try
    List.Capacity:=TV.SelectionCount;
    for i:=0 to TV.SelectionCount-1 do
      begin
        // Ищем, может кого из родителей уже занесли в список на выбывание ;)
        f:=False;
        for j:=0 to List.Count-1 do
          begin
            f:=HasAsParent(TV.Selections[i],TTreeNode(List[j]));
            if f then
              Break;
          end;
        if f then // Родителя удалят, так что текущий узел удалять не нужно
          Continue;
        // Теперь нужно удалить всех детей, которые уже были записаны в список
        for j:=List.Count-1 downto 0 do
          if HasAsParent(TTreeNode(List[j]),TV.Selections[i]) then
            List.Delete(j);
        // Вот теперь можно со спокойной душей добавлять узел в список..
        List.Add(TV.Selections[i])
      end;
      for i:=0 to List.Count-1 do
        TTreeNode(List[i]).Delete;
  finally
    List.Free;
  end;
end; {$endregion}
procedure AddTagPanel(constref ind:integer);                                         inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  P_TreeView_Attributes_Cells:=TPanel.Create(Nil);
  with F_MainForm,TV_Scene_Tree,P_TreeView_Attributes_Cells do
    begin
      AnchorParallel(akRight,0,SB_TreeView_Object_Tags);
      BevelColor:=clGray;
      Parent    :=SB_TreeView_Object_Tags;
      Left      :=1;
      Top       :=Items[ind].Top+1;
      Width     :=62;
      Height    :=27;
      Color     :=$00ABAFA3;
      Caption   :=IntToStr(ind);
      Font.Color:=clBlue;
    end;
end; {$endregion}
procedure CreateNode(item_text1,item_text2:ansistring; is_first_node:boolean=False); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  item_text: ansistring;
  ind       : integer;
begin
  with F_MainForm,TV_Scene_Tree do
    begin
      Items.BeginUpdate;
      item_text:=item_text1+item_text2;
      if (not is_first_node) then
        begin
          if (Selected=Nil) then
            ind:=Items.AddChild(Items[0],item_text).AbsoluteIndex
          else
            ind:=Items.AddChild(Selected,item_text).AbsoluteIndex;
        end
      else
        begin
          Items.AddFirst(Nil,item_text).Expanded:=True;
          ind                                   :=0;
        end;
      with obj_var do
        CreateNodeData(Items[ind],obj_cnt-1);
      AddTagPanel(ind);
      Items.EndUpdate;
    end;
end; {$endregion}
{$endregion}
{UI} {$region -fold}
constructor TF_MainForm.Create                                 (TheOwner:TComponent);                                                      {$region -fold}
begin
  inherited Create(TheOwner);
end; {$endregion}
procedure TF_MainForm.SB_TreeView_Object_TagsMouseWheelDown    (sender:TObject; shift:TShiftState; mousepos:TPoint; var handled:boolean);  {$region -fold}
begin
  TV_Scene_Tree.Perform(WM_VSCROLL,MakeWParam(SB_LINEDOWN,0),0);
end; {$endregion}
procedure TF_MainForm.SB_TreeView_Object_TagsMouseWheelUp      (sender:TObject; shift:TShiftState; mousepos:TPoint; var handled:boolean);  {$region -fold}
begin
  TV_Scene_Tree.Perform(WM_VSCROLL,MakeWParam(SB_LINEUP,0),0);
end; {$endregion}
procedure TF_MainForm.MI_Add_GroupClick                        (sender:TObject);                                                           {$region -fold}
var
  world_axis_shift: TPtPos;
  items_text      : ansistring;
begin
  with TV_Scene_Tree,obj_var do
    begin
      if (srf_var<>Nil) then
        world_axis_shift:=srf_var.world_axis_shift
      else
        world_axis_shift:=Default(TPtPos);
      Add(kooGroup,world_axis_shift);
      CreateNode('Group',IntToStr(group_cnt));
      ObjIndsCalc;
      ScTIndsCalc;
      //Items.AddChild(Items[0],items_text).MakeVisible;
    end;
  DrawObjectInfo0;
end; {$endregion}
procedure TF_MainForm.MI_Remove_ObjectClick                    (sender:TObject);                                                           {$region -fold}
begin
  if (TV_Scene_Tree.Selected=Nil) then
    begin
      ShowMessage('Nothing selected');
      Exit;
    end;
  if (TV_Scene_Tree.Selected.Level=0) then
    begin
      ShowMessage('Cant delete the root node');
      Exit;
    end;
  DeleteSelectedNodes(TV_Scene_Tree);
end; {$endregion}
procedure TF_MainForm.MI_Group_ObjectsClick                    (sender:TObject);                                                           {$region -fold}
var
  j,m: integer;

  function FirstSelectedNode: integer; {$region -fold}
    var
      i,m: integer;
  begin
    Randomize;
    m:=0;
    with TV_Scene_Tree do
      if Items.IsMultiSelection then
        for i:=1 to Items.Count-1 do
          case Items[i].Selected of
            False: Inc(m);
            True : Break;
          end;
    Result:=m;
  end; {$endregion}

begin
  m:=FirstSelectedNode;
  with TV_Scene_Tree do
    begin
      Items.BeginUpdate;
      Items.Insert(Items[m+1],'Group'+IntToStr(Random(100)));
      for j:=1 to Items.Count-1 do
        if Items[j].MultiSelected then
          Items[j].MoveTo(Items[m+1],naAddChild);
      Items[m+1].Expanded:=True;
      if (Selected<>Nil) then
        Items.ClearMultiSelection(True);
      obj_var.Add(kooGroup,srf_var.world_axis_shift);
      with obj_var do
        CreateNodeData(Items[m+1],obj_cnt-1);
      ObjIndsCalc;
      ScTIndsCalc;
      Items.EndUpdate;
    end;
end; {$endregion}
procedure TF_MainForm.MI_Delete_Without_ChildrenClick          (sender:TObject);                                                           {$region -fold}
begin

end; {$endregion}
procedure TF_MainForm.MI_Delete_All_GroupsClick                (sender:TObject);                                                           {$region -fold}
begin
end; {$endregion}
procedure TF_MainForm.MI_Select_AllClick                       (sender:TObject);                                                           {$region -fold}
var
  i: integer;
begin
  for i:=1 to TV_Scene_Tree.Items.Count-1 do
    TV_Scene_Tree.Items[i].Selected:=True;
end; {$endregion}
procedure TF_MainForm.MI_Fold_SelectedClick                    (sender:TObject);                                                           {$region -fold}
var
  i: integer;
begin
  for i:=1 to TV_Scene_Tree.Items.Count-1 do
    if TV_Scene_Tree.Items[i].Selected then
      TV_Scene_Tree.Items[i].Expanded:=False;
end; {$endregion}
procedure TF_MainForm.MI_Unfold_SelectedClick                  (sender:TObject);                                                           {$region -fold}
var
  i: integer;
begin
  for i:=1 to TV_Scene_Tree.Items.Count-1 do
    if TV_Scene_Tree.Items[i].MultiSelected then
      TV_Scene_Tree.Items[i].Expanded:=True;
end; {$endregion}
procedure TF_MainForm.MI_Goto_First_ObjectClick                (sender:TObject);                                                           {$region -fold}
begin
  TV_Scene_Tree.Items[1].Selected:=True;
end; {$endregion}
procedure TF_MainForm.MI_Goto_Last_ObjectClick                 (sender:TObject);                                                           {$region -fold}
begin
  TV_Scene_Tree.Items[TV_Scene_Tree.Items.Count-1].Selected:=True;
end; {$endregion}
procedure TF_MainForm.TV_Scene_TreeDragOver                    (sender,source:TObject; x,y:integer; state:TDragState; var accept:boolean); {$region -fold}
begin
  accept:=True; // If TRUE then accept the draged item
end; {$endregion}
procedure TF_MainForm.TV_Scene_TreeMouseDown                   (sender:TObject; button:TMouseButton; shift:TShiftState; x,y:integer);      {$region -fold}
var
  target_node: TTreeNode;
  s          : string;

  procedure InitDataObjSelInds(constref b0,b1:boolean); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
  begin
   { with obj_var do
      case PNodeData(target_node.Data)^.kind_of_object of
        kooGroup:
          begin
            group_selected:=b0;
            if b0 then
              begin
                if b1 then
                  group_inds_cnt:=0;
                Inc(group_inds_cnt);
              end;
            {if b2 then
              FillDWord(@group_inds_arr,}
          end;
        kooActor:
          begin
            actor_selected:=b0;

          end;
        kooPrtcl:
          begin
            prtcl_selected:=b1;

          end;
        kooCurve:
          begin
            curve_selected:=b1;

          end;
        kooTiles:
          begin
            tiles_selected:=b1;

          end;
      end;}
  end; {$endregion}

begin
  with TV_Scene_Tree do
    if (button=mbLeft) then
      begin
        ReadOnly     :=False;
        source_node_x:=x;
        source_node_y:=y;
        target_node  :=GetNodeAt(x,y);
        if (target_node<>Nil) then
          begin
            InitDataObjSelInds(True,(shift<>[ssCtrl]));
            BeginDrag(True);
            //s:={GetEnumName(TypeInfo(TKindOfObject),Ord(obj_var.obj_arr[PNodeData(target_node.Data)^.g_ind].koo));}{IntToStr(obj_var.obj_inds_arr[PNodeData(target_node.Data)^.g_ind]);}{GetEnumName(TypeInfo(TKindOfObject),Ord(PNodeData(target_node.Data)^.obj^.koo));}
            //Delete(s,1,3);
            //Memo1.Lines.Text:=IntToStr(PNodeData(target_node.Data)^.obj^.k_ind);
            //Memo1.Lines.Text:=s;
           {Memo2.Lines.Add(IntToStr(PNodeData(TargetNode.Data)^.curve_prop.obj_ind));
            Memo2.Lines.Add(IntToStr(PNodeData(TargetNode.Data)^.curve_prop.pts_cnt));}
          end
        else
        if (Selected<>Nil) then
          begin
            InitDataObjSelInds(False,(shift<>[ssCtrl]));
            Items.ClearMultiSelection(True);
          end;
        ReadOnly:=True;
      end;
end; {$endregion}
procedure TF_MainForm.TV_Scene_TreeDblClick                    (sender:TObject);                                                           {$region -fold}
begin

end; {$endregion}
procedure TF_MainForm.TV_Scene_TreeEditing                     (sender:TObject; node:TTreeNode; var allowedit:boolean);                    {$region -fold}
begin
  KeysDisable;
end; {$endregion}
procedure TF_MainForm.TV_Scene_TreeEditingEnd                  (sender:TObject; node:TTreeNode; cancel:boolean);                           {$region -fold}
begin
  KeysEnable;
end; {$endregion}
procedure TF_MainForm.TV_Scene_TreeKeyDown                     (sender:TObject; var key:word; shift:TShiftState);                          {$region -fold}
begin
  with TV_Scene_Tree do
    begin
      //if (Selected.Index=0) then

      case key of
        40: Items[Selected.Index+1].Selected;
        38:
          begin
            if (Selected.Index>2) then
              Items[Selected.Index-1].Selected
            else
              Items[Selected.Index+1].Selected;
          end;
      end;
      {case key of
        13:
          if (Selected<>Nil) then
              Selected.EditText;
      end;}
    end;
end; {$endregion}
procedure TF_MainForm.TV_Scene_TreeKeyPress                    (sender:TObject; var key:char);                                             {$region -fold}
begin
  with TV_Scene_Tree do
    case key of
      #13:
        if (Selected<>Nil) then
            Selected.EditText;
      #40: Items[Selected.Index+1].Selected;
      #38:
        begin
          if (Selected.Index>2) then
            Items[Selected.Index-1].Selected
          else
            Items[Selected.Index+1].Selected;
        end;
    end;
  //Mouse_Event
end; {$endregion}
procedure TF_MainForm.TV_Scene_TreeDragDrop                    (sender,source:TObject; x,y:integer);                                       {$region -fold}
var
  source_node,target_node: TTreeNode;
begin
  with TV_Scene_Tree do
    begin
      source_node:=GetNodeAt(source_node_x,source_node_y);
      target_node:=GetNodeAt(x,y);
      if (target_node=Nil) then
        begin
          EndDrag(False);
          if (Selected<>Nil) then
            Items.ClearMultiSelection(True);
          target_node:=Items[0];
        end;
      source_node.MoveTo(target_node,naAddChild);
    end;
  ObjIndsCalc;
  ScTIndsCalc;
  srf_var.EventGroupsCalc(calc_arr,[30]);
end; {$endregion}
procedure TF_MainForm.S_TreeView_SplitterChangeBounds          (sender:TObject);                                                           {$region -fold}
begin
  {$ifdef Windows}
  Application.ProcessMessages;
  {$else}
  P_TreeView_Attributes.Update;
  {$endif}
  if (S_TreeView_Splitter.left<F_MainForm.width-TV_Scene_Tree.width+4) then
    S_TreeView_Splitter.left:=F_MainForm.width-TV_Scene_Tree.width+4;
  treeview_splitter_shift:=S_TreeView_Splitter.left-S_Splitter3.left;
end; {$endregion}
// (Object Properties) Свойства обьекта:
procedure TF_MainForm.SB_Object_PropertiesMouseEnter           (sender:TObject);                                                           {$region -fold}
begin
  SB_Object_Properties.Color:=HighLight(SB_Object_Properties.Color,0,0,0,0,0,16);
  P_Object_Properties .Color:=HighLight(P_Object_Properties .Color,0,0,0,0,0,16);
end; {$endregion}
procedure TF_MainForm.SB_Object_PropertiesMouseLeave           (sender:TObject);                                                           {$region -fold}
begin
  SB_Object_Properties.Color:=Darken(SB_Object_Properties.Color,0,0,0,0,0,16);
  P_Object_Properties .Color:=Darken(P_Object_Properties .Color,0,0,0,0,0,16);
end; {$endregion}
procedure TF_MainForm.SE_Object_Properties_Parallax_ShiftChange(sender:TObject);                                                           {$region -fold}
begin
  obj_var.global_prop.parallax_shift.x:=SE_Object_Properties_Parallax_Shift.value;
  obj_var.global_prop.parallax_shift.y:=SE_Object_Properties_Parallax_Shift.value;
end; {$endregion}
// (Tag    Properties) Свойства тега:
procedure TF_MainForm.SB_Tag_PropertiesMouseEnter              (sender:TObject);                                                           {$region -fold}
begin
  SB_Tag_Properties.Color:=HighLight(SB_Tag_Properties.Color,0,0,0,0,0,16);
  P_Tag_Properties .Color:=HighLight(P_Tag_Properties .Color,0,0,0,0,0,16);
end; {$endregion}
procedure TF_MainForm.SB_Tag_PropertiesMouseLeave              (sender:TObject);                                                           {$region -fold}
begin
  SB_Tag_Properties.Color:=Darken(SB_Tag_Properties.Color,0,0,0,0,0,16);
  P_Tag_Properties .Color:=Darken(P_Tag_Properties .Color,0,0,0,0,0,16);
end; {$endregion}
{$endregion}

// (Game Loop) Игровой цикл:
{LI} {$region -fold}
{$endregion}
{UI} {$region -fold}
procedure TF_MainForm.Tic             (sender:TObject; var done:boolean); {$region -fold}
var
  d                  : TPoint;
  i,j,x,y            : integer;
  color_info         : TColorInfo;
  t                  : integer;
  vec_x_dist_sht     : integer;
  velocity           : integer=4;
  distance           : integer=4;
  r_x,r_y            : longword;
  sprite_rect_arr_ptr: PPtPos;
  useless_arr_ptr    : PByte;
begin

  Sleep(12);

  with srf_var,sln_var,tex_var,fast_physics_var,fast_fluid_var do
    begin

      if (not is_active) then
        begin
          Inc(downtime_counter);
          if (downtime_counter>downtime) then
            Exit;
        end
      else
        downtime_counter:=0;

      LowerBmpToMainBmp;
      Randomize;
      t:=200;
      GetCursorPos(d);
      d:=ScreenToClient(d);

      with fast_actor_set_var.d_icon do
        begin

          begin
            col_trans_arr[00]+=4;
            col_trans_arr[01]+=4;
            col_trans_arr[02]+=4;
            col_trans_arr[03]+=4;
            col_trans_arr[04]+=4;
            col_trans_arr[05]+=4;
            col_trans_arr[06]+=4;
            col_trans_arr[07]+=4;
            col_trans_arr[08]+=4;
            col_trans_arr[09]+=4;
            col_trans_arr[10]+=4;
            col_trans_arr[11]+=4;
            col_trans_arr[12]+=4;
            col_trans_arr[13]+=4;
            col_trans_arr[14]+=4;
            col_trans_arr[15]+=4;
          end;

          SetColorInfo(clRed,color_info);
          {for i:=0 to 1000 do
            CircleHighlight(tex_bmp_rect.left+Random(tex_bmp_rect.width-1),
                            tex_bmp_rect.top+Random(tex_bmp_rect.height-1),
                            surf_bmp_handle,
                            inner_window_rect,
                            surf_bmp.width,
                            color_info,
                            Random(032),
                            Random(256));}

          if (sln_obj_cnt>0) then
            for i:=0 to sln_obj_cnt-1 do
              begin
                if (sln_obj_pts_cnt[i]=1) then
                  begin
                    CircleHighlight(Trunc(sln_pts[partial_pts_sum[i]].x),
                                    Trunc(sln_pts[partial_pts_sum[i]].y),
                                    srf_bmp_ptr,
                                    inn_wnd_rct,
                                    srf_bmp.width,
                                    color_info,
                                    sln_sprite_counter_rad_arr[i],
                                    sln_sprite_counter_pow_arr[i]);
                    Continue;
                  end;
                if (sln_obj_pts_cnt[i]>1) then
                  begin
                    CircleHighlight(Trunc(sln_pts[partial_pts_sum[i]+sln_sprite_counter_pos_arr[i]].x),
                                    Trunc(sln_pts[partial_pts_sum[i]+sln_sprite_counter_pos_arr[i]].y),
                                    srf_bmp_ptr,
                                    inn_wnd_rct,
                                    srf_bmp.width,
                                    color_info,
                                    sln_sprite_counter_rad_arr[i],
                                    sln_sprite_counter_pow_arr[i]);
                    if (sln_sprite_counter_pos_arr[i]=sln_obj_pts_cnt[i]-1) then
                        sln_sprite_counter_pos_arr[i]:=0
                    else
                      Inc(sln_sprite_counter_pos_arr[i]);
                    Continue;
                  end;
              end;

          //for i:=0 to SE_Count_X.Value-1 do
            {PPBlur(surf_bmp_handle,
                   ClippedRect(inner_window_rect,tex_bmp_rect),
                   surf_bmp.width,SE_Count_Y.Value-1);}
          //fx_arr[0].fx_id:=SE_Count_Y.Value;
          srf_bmp.Canvas.TextOut(100,100,'Start Demo');
          srf_bmp.Canvas.TextOut(100,140,'Settings'  );
          srf_bmp.Canvas.TextOut(100,180,'Credits'   );
          srf_bmp.Canvas.TextOut(100,220,'Exit'      );

          {fx_arr[1].nt_pix_cfx_type:=SE_Count_X.Value-1;
          fx_arr[1].pt_pix_cfx_type:=SE_Count_X.Value-1;}

          {fast_actor_set_var.act_pos_arr[fast_actor_set_var.act_cnt-1].x:=d.x{-bmp_ftimg_width >>1};
          fast_actor_set_var.act_pos_arr[fast_actor_set_var.act_cnt-1].y:=d.y{-bmp_ftimg_height>>1};
          bmp_ftimg_left  :=Trunc(fast_actor_set_var.act_pos_arr[fast_actor_set_var.act_cnt-1].x);
          bmp_ftimg_top   :=Trunc(fast_actor_set_var.act_pos_arr[fast_actor_set_var.act_cnt-1].y);
          bmp_ftimg_right :=bmp_ftimg_left+bmp_ftimg_width ;
          bmp_ftimg_bottom:=bmp_ftimg_top +bmp_ftimg_height;}

          {bmp_ftimg_left  :=d.x-bmp_ftimg_width >>1;
          bmp_ftimg_top   :=d.y-bmp_ftimg_height>>1;
          bmp_ftimg_right :=bmp_ftimg_left+bmp_ftimg_width ;
          bmp_ftimg_bottom:=bmp_ftimg_top +bmp_ftimg_height;}


          sprite_rect_arr_ptr:=@sprite_rect_arr[0];
          useless_arr_ptr    :=@useless_arr_   [0];
          for i:=0 to SE_Count_X.Value-1 do
            begin
              SetRctPos((sprite_rect_arr_ptr+i)^.x,
                        (sprite_rect_arr_ptr+i)^.y);
              SdrProc[(useless_arr_ptr+i)^];
            end;

          //for i:=0 to SE_Count_X.Value-1 do
            {PPHighLight(srf_bmp_ptr,
                        ClippedRect(inner_window_rect,PtBounds(d.x-64,d.y-64,128,128)),
                        surf_bmp.width);}
          {CircleHighlight(d.x,d.y,
                          surf_bmp_ptr,
                          inn_wnd_rect,
                          surf_bmp.width,
                          color_info,
                          128,
                          045);}

          {PPBlur(surf_bmp_ptr,
                 inn_wnd_rect,
                 surf_bmp.width,
                 10);}

          //////////////// ----- max sprites count without lags
          //////////////// ----- col     val
          {Monochrome } // ----- 266;    278;    340;   1233; 1227;
          {Additive   } // ----- 047;    070;    086;
          {Alphablend } // ----- 089;    108;    120;
          {Inverse    } // ----- 103;    167;    194;
          {Highlighted} // ----- 048;    068;    081;
          {Darkened   } // ----- 052;    072;    085;
          {GrayscaleR } // ----- 085;    128;    135;
          ////////////////

          {Points Cloud--} {$region -fold}
          {SetColorInfo(clRed,color_info);
          for i:=0 to 1000-1 do
            Point(tex_bmp_rect.left+Random(tex_bmp_rect.width-1),
                  tex_bmp_rect.top+Random(tex_bmp_rect.height-1),
                  surf_bmp_ptr,
                  surf_bmp.width,
                  color_info,
                  inn_wnd_rect);} {$endregion}

          {Actor Blur----} {$region -fold}
          {clip_mrg:=1;
          SetRectDst;
          SetRectSrc;
          arr_src_sht:=ClippedArr(rect_src,
                                  rect_dst,
                                  bmp_ftimg_width);
          for i:=0 to 0{sprite_count-1} do
            PPBlur(bmp_color,
                   arr_src_sht,
                   rect_src,
                   rect_dst,
                   surf_bmp.width,
                   bmp_ftimg_width,
                   surf_bmp_handle);} {$endregion}

          {Actor Colorize} {$region -fold}
          {clip_mrg:=0;
          SetRectDst;
          SetRectSrc;
          arr_src_sht:=ClippedArr(rect_src,
                                  rect_dst,
                                  bmp_ftimg_width);
          PPColorCorrection1(@ColorizeRMDec,
                             @ColorizeRPDec,
                             bmp_color,
                             arr_src_sht,
                             rect_src,
                             rect_dst,
                             surf_bmp.width,
                             bmp_ftimg_width,
                             surf_bmp_handle,
                             col_trans_var.grayscale_r_val);} {$endregion}

          {Bullets-------} {$region -fold}
          {begin
            SetColorInfo(clBlue,color_info);
            for i:=0 to 10 do
              begin
                if PointCollDraw(vec_x,
                                 vec_y,
                                 width,
                                 coll_box_arr,
                                 inner_window_rect,
                                 0) then
                  begin
                    vec_x         -=0{velocity}{d.x-t+Random(t<<1)};
                    vec_x_dist_sht:=vec_x-i*distance;
                  end
                else
                  begin
                    vec_x         +=velocity{d.x-t+Random(t<<1)};
                    vec_x_dist_sht:=vec_x+i*distance;
                  end;
                Point(vec_x_dist_sht,
                      vec_y,
                      surf_bmp_handle,
                      surf_bmp.width,
                      color_info,
                      inner_window_rect);
              end;
            ArrClear(coll_box_arr,inner_window_rect,width);
          end;} {$endregion}

          {Fluid Simul.--} {$region -fold}
          {if (spline_pts_cnt>0) then
            begin
              r_x            :=tex_bmp_rect.left;
              r_y            :=tex_bmp_rect.top;
              pts_dist_acc   :=r_x;
              for i:=0 to spline_obj_pts_cnt[spline_obj_cnt-1]-1 do
                begin
                  spline_pts[i].x:=pts_dist_acc;
                  Inc(pts_dist_acc,pts_dist);
                end;
              for i:=0 to spline_obj_pts_cnt[spline_obj_cnt-1]-1 do
                spline_pts[i].y:=(a0/a1)*exp((r_x-spline_pts[i].x)/a2)*sin(a3-a4*(r_x-spline_pts[i].x))+r_y;
              SetColorInfo(clRed{clRed},color_info);
              for i:=0 to spline_obj_pts_cnt[spline_obj_cnt-1]-2 do
                Line(Trunc(spline_pts[i+0].x),
                     Trunc(spline_pts[i+0].y),
                     Trunc(spline_pts[i+1].x),
                     Trunc(spline_pts[i+1].y),
                     surf_bmp_handle,
                     surf_bmp.width,
                     color_info,
                     inner_window_rect);
              SetColorInfo(clRed{clWhite},color_info);
              for i:=0 to spline_obj_pts_cnt[spline_obj_cnt-1]-1 do
                Point(Trunc(spline_pts[i].x),
                      Trunc(spline_pts[i].y),
                      surf_bmp_handle,
                      surf_bmp.width,
                      color_info,
                      inner_window_rect);
              Dec(a3,1);
              if (a3<=0) then
                a3:=80;
              Dec(a0,1);
              if (a0<=0) then
                a0:=0;
            end;} {$endregion}

          {Fluid Colorize} {$region -fold}
          {PPColorCorrectionP0(@ColorizeBP,
                              surf_bmp_ptr,
                              ClippedRect(inn_wnd_rect,
                                          tex_bmp_rect),
                              surf_bmp.width,
                              SE_Count_X.Value-1);} {$endregion}

          {Fluid Blur----} {$region -fold}
          {for i:=0 to 0 do
            PPBlur(surf_bmp_handle,
                   ClippedRect(inner_window_rect,tex_bmp_rect),
                   surf_bmp.width);} {$endregion}

        end;

        CnvToCnv(srf_bmp_rct,Canvas,srf_bmp.Canvas,SRCCOPY);

    end;

  Done:=false;

end; {$endregion}
procedure TF_MainForm.T_Game_LoopTimer(sender:TObject);                   {$region -fold}
var
  sln_eds_var_ptr      : PFastLine;
  sln_pts_ptr          : PPtPosF;
  sln_pts_ptr2         : PPtPosF;
  pt                   : TPtPos;
  rct                  : TPtRect;
  sln_obj_pts_cnt_ptr  : PInteger;
  partial_pts_sum_ptr  : PInteger;
  i,j,x,y              : integer;
  color_info           : TColorInfo;
  t                    : integer;
  vec_x_dist_sht       : integer;
  velocity             : integer=4;
  distance             : integer=4;
  sprite_rect_arr_ptr  : PPtPos;
  useless_arr_ptr      : PByte;
  m                    : byte;
  f                    : TPtPos;
  n                    : integer;
  x0,y0,x1,y1,v1,w1,k,b: double;
  str                  : string;
  projectile_arr_ptr   : PProjectile;
begin

  with srf_var,sln_var,tex_var,srf_var,tex_var,sln_var,sel_var,crc_sel_var,pvt_var,fast_physics_var,fast_fluid_var do
    begin

      Randomize;
      t:=200;
      GetCursorPos(cur_pos);
      cur_pos:=ScreenToClient(cur_pos);

      if (CB_Spline_Mode.ItemIndex=0) then
        if draw_spline then
          begin
            AddPoint
            (
              cur_pos.x,
              cur_pos.y,
              low_bmp_ptr,
              low_bmp.width,
              color_info,
              inn_wnd_rct,
              add_spline_calc,
              True
            );
            CnvToCnv
            (
              srf_bmp_rct,
              Canvas,
              low_bmp.Canvas,
              SRCCOPY
            );
          end;

      if dir_a then
        begin
          main_char_pos.x-=parallax_shift.x;
          main_char_pos.x+=main_char_speed;
          MovLeft;
          if low_bmp_draw then
            FilLeft
            (
              low_bmp_ptr,
              low_bmp.width,
              low_bmp.height,
              inn_wnd_rct
            );
        end;
      if dir_d then
        begin
          main_char_pos.x+=parallax_shift.x;
          main_char_pos.x-=main_char_speed;
          MovRight;
          if low_bmp_draw then
            FilRight
            (
              low_bmp_ptr,
              low_bmp.width,
              low_bmp.height,
              inn_wnd_rct
            );
        end;
      if dir_w then
        begin
          main_char_pos.y-=parallax_shift.y;
          main_char_pos.y+=main_char_speed;
          MovUp;
          if low_bmp_draw then
            FilUp
            (
              low_bmp_ptr,
              low_bmp.width,
              low_bmp.height,
              inn_wnd_rct
            );
        end;
      if dir_s then
        begin
          main_char_pos.y+=parallax_shift.y;
          main_char_pos.y-=main_char_speed;
          MovDown;
          if low_bmp_draw then
            FilDown
            (
              low_bmp_ptr,
              low_bmp.width,
              low_bmp.height,
              inn_wnd_rct
            );
        end;

      if low_bmp_draw then
        LowerBmpToMainBmp
      else
        PPFloodFill(srf_bmp_ptr,inn_wnd_rct,srf_bmp.width,bg_color,flood_fill_inc);
      flood_fill_inc:=not flood_fill_inc;

      {Mask Template Sprites Drawing}
      with tlm_var do
        begin

          {with mask_template_arr2[0] do
              begin
                SetRctPos(world_axis.x-(bmp_ftimg_width_origin *mask_tpl_sprite_w_h.x)>>1+srf_var.world_axis_shift.x,
                          world_axis.y-(bmp_ftimg_height_origin*mask_tpl_sprite_w_h.y)>>1+srf_var.world_axis_shift.y);
                SetBckgd
                (
                  srf_bmp_ptr,
                  srf_bmp.width,
                  srf_bmp.height
                );
                with mask_tpl_sprite_ptr^ do
                  SetBckgd
                  (
                    srf_bmp_ptr,
                    srf_bmp.width,
                    srf_bmp.height
                  );
                FilMaskTemplate0;
              end;}

          //for i:=0 to SE_Spline_Pts_Freq.Value-1 do
          {with mask_template_arr2[High(mask_template_arr2)] do
            begin
              SetRctPos(world_axis.x-(bmp_ftimg_width_origin *mask_tpl_sprite_w_h.x)>>1+srf_var.world_axis_shift.x,
                        world_axis.y-(bmp_ftimg_height_origin*mask_tpl_sprite_w_h.y)>>1+srf_var.world_axis_shift.y);
              SetBckgd
              (
                srf_bmp_ptr,
                srf_bmp.width,
                srf_bmp.height
              );
              with mask_tpl_sprite_ptr^ do
                SetBckgd
                (
                  srf_bmp_ptr,
                  srf_bmp.width,
                  srf_bmp.height
                );
              FilMaskTemplate1;
            end;}
          {if show_tile_map then
            for i:=0 to High(tilemap_arr2) do
              with tilemap_arr2[i{High(mask_template_arr2)}] do
                begin
                  SetRctPos(world_axis.x-(bmp_ftimg_width_origin *tilemap_sprite_w_h.x)>>1+srf_var.world_axis_shift.x,
                            world_axis.y-(bmp_ftimg_height_origin*tilemap_sprite_w_h.y)>>1+srf_var.world_axis_shift.y);
                  SetBckgd
                  (
                    srf_bmp_ptr,
                    srf_bmp.width,
                    srf_bmp.height
                  );
                  with tilemap_sprite_ptr^ do
                    SetBckgd
                    (
                      srf_bmp_ptr,
                      srf_bmp.width,
                      srf_bmp.height
                    );
                  //FilMaskTemplate0;
                  FilMaskTemplate1;
                  //FilMaskTemplate2;
                  bmp_bckgd_ptr:=@coll_arr[0];
                end;}

        end;

      with fast_actor_set_var.d_icon do
        begin

          begin
            col_trans_arr[04]:=128;
            {col_trans_arr[00]+=4;
            col_trans_arr[01]+=4;
            col_trans_arr[02]+=4;
            col_trans_arr[03]+=4;
            col_trans_arr[04]+=4;
            col_trans_arr[05]+=4;
            col_trans_arr[06]+=4;
            col_trans_arr[07]+=4;
            col_trans_arr[08]+=4;
            col_trans_arr[09]+=4;
            col_trans_arr[10]+=4;
            col_trans_arr[11]+=4;
            col_trans_arr[12]+=4;
            col_trans_arr[13]+=4;
            col_trans_arr[14]+=4;
            col_trans_arr[15]+=4;}
          end;

          SetColorInfo(clRed,color_info);

          if (sln_obj_cnt>0) then
            begin
              for i:=0 to sln_obj_cnt-1 do
                begin
                  if (sln_obj_pts_cnt[i]=1) then
                    begin
                      CircleHighlight(Trunc(sln_pts[partial_pts_sum[i]].x)+world_axis_shift.x,
                                      Trunc(sln_pts[partial_pts_sum[i]].y)+world_axis_shift.y,
                                      srf_bmp_ptr,
                                      inn_wnd_rct,
                                      srf_bmp.width,
                                      color_info,
                                      sln_sprite_counter_rad_arr[i],
                                      sln_sprite_counter_pow_arr[i]);
                      Continue;
                    end;
                  if (sln_obj_pts_cnt[i]>1) then
                    begin
                      {for j:=0 to sln_obj_pts_cnt[i]-1 do
                        CircleHighlight(Trunc(sln_pts[partial_pts_sum[i]+j].x),
                                        Trunc(sln_pts[partial_pts_sum[i]+j].y),
                                        srf_bmp_ptr,
                                        inn_wnd_rct,
                                        srf_bmp.width,
                                        color_info,
                                        sln_sprite_counter_rad_arr[i],
                                        sln_sprite_counter_pow_arr[i]);}
                      CircleHighlight(Trunc(sln_pts[partial_pts_sum[i]+sln_sprite_counter_pos_arr[i]].x)+world_axis_shift.x,
                                      Trunc(sln_pts[partial_pts_sum[i]+sln_sprite_counter_pos_arr[i]].y)+world_axis_shift.y,
                                      srf_bmp_ptr,
                                      inn_wnd_rct,
                                      srf_bmp.width,
                                      color_info,
                                      sln_sprite_counter_rad_arr[i],
                                      sln_sprite_counter_pow_arr[i]);
                      if (sln_sprite_counter_pos_arr[i]=sln_obj_pts_cnt[i]-1) then
                          sln_sprite_counter_pos_arr[i]:=0
                      else
                        Inc(sln_sprite_counter_pos_arr[i]);
                      Continue;
                    end;
                end;


              with inn_wnd_rct do
                rct:=PtRct(left,top,right-1,bottom-1);
              for i:=0 to sln_obj_cnt-1 do
                begin
                  SetColorInfo(SetColorInv(clRed),color_info,False);
                  LineABCG
                  (
                    sln_pts,
                    partial_pts_sum[i],
                    partial_pts_sum[i]+sln_obj_pts_cnt[i]-1,
                    srf_bmp_ptr,
                    srf_bmp.width,
                    color_info,
                    rct,
                    world_axis_shift
                  );
                end;

            end;

      {srf_bmp.Canvas.TextOut(100,100,'Start Demo');
      srf_bmp.Canvas.TextOut(100,140,'Settings'  );
      srf_bmp.Canvas.TextOut(100,180,'Credits'   );
      srf_bmp.Canvas.TextOut(100,220,'Exit'      );}

     {fx_arr[1].nt_pix_cfx_type:=SE_Count_X.Value-1;
      fx_arr[1].pt_pix_cfx_type:=SE_Count_X.Value-1;}

     {fast_actor_set_var.act_pos_arr[fast_actor_set_var.act_cnt-1].x:=cur_pos.x{-bmp_ftimg_width >>1};
      fast_actor_set_var.act_pos_arr[fast_actor_set_var.act_cnt-1].y:=cur_pos.y{-bmp_ftimg_height>>1};
      bmp_ftimg_left  :=Trunc(fast_actor_set_var.act_pos_arr[fast_actor_set_var.act_cnt-1].x);
      bmp_ftimg_top   :=Trunc(fast_actor_set_var.act_pos_arr[fast_actor_set_var.act_cnt-1].y);
      bmp_ftimg_right :=bmp_ftimg_left+bmp_ftimg_width ;
      bmp_ftimg_bottom:=bmp_ftimg_top +bmp_ftimg_height;}

     {bmp_ftimg_left  :=cur_pos.x-bmp_ftimg_width >>1;
      bmp_ftimg_top   :=cur_pos.y-bmp_ftimg_height>>1;
      bmp_ftimg_right :=bmp_ftimg_left+bmp_ftimg_width ;
      bmp_ftimg_bottom:=bmp_ftimg_top +bmp_ftimg_height;}

      (*sprite_rect_arr_ptr:=@sprite_rect_arr[0];
      useless_arr_ptr    :=@useless_arr_   [0];
      for i:=0 to SE_Count_X.Value-1 do
        begin
          SetRctPos((sprite_rect_arr_ptr+i)^.x,
                    (sprite_rect_arr_ptr+i)^.y);
          SdrProc[(useless_arr_ptr+i)^];
        end;*)

      {for i:=0 to SE_Count_X.Value-1 do
        begin
          sln_var.eds_var[i].fst_img.SetRectPos(cur_pos.x-sln_var.eds_var[i].fst_img.bmp_ftimg_width>>1,
                                                cur_pos.y-sln_var.eds_var[i].fst_img.bmp_ftimg_width>>1);
          sln_var.eds_var[i].fst_img.SdrProc[1];
          sln_var.pts_var[i].fst_img.SetRectPos(cur_pos.x-sln_var.pts_var[i].fst_img.bmp_ftimg_width>>1,
                                                cur_pos.y-sln_var.pts_var[i].fst_img.bmp_ftimg_width>>1);
          sln_var.pts_var[i].fst_img.SdrProc[1];
        end;}

      //for i:=0 to SE_Count_X.Value-1 do
        {PPHighLight(surf_bmp_handle,
                    ClippedRect(inner_window_rect,PtBounds(d.x-64,d.y-64,128,128)),
                    surf_bmp.width);}
     {CircleHighlight(d.x,d.y,
                      surf_bmp_ptr,
                      inn_wnd_rct,
                      surf_bmp.width,
                      color_info,
                      128,
                      045);}

      {PPBlur(surf_bmp_ptr,
             inn_wnd_rct,
             surf_bmp.width,
             10);}

      //////////////// ----- max sprites count without lags
      //////////////// ----- col     val
      {Monochrome } // ----- 266;    278;    340;   1233; 1227;
      {Additive   } // ----- 047;    070;    086;
      {Alphablend } // ----- 089;    108;    120;
      {Inverse    } // ----- 103;    167;    194;
      {Highlighted} // ----- 048;    068;    081;
      {Darkened   } // ----- 052;    072;    085;
      {GrayscaleR } // ----- 085;    128;    135;
      ////////////////

      {Points Cloud------} {$region -fold}
      {SetColorInfo(clGreen,color_info);
      for i:=0 to 1000 do
        Point(Trunc(tex_bmp_rct_pts[0].x)+Random(Trunc(tex_bmp_rct_pts[1].x-tex_bmp_rct_pts[0].x)-1)+1,
              Trunc(tex_bmp_rct_pts[0].y)+Random(Trunc(tex_bmp_rct_pts[1].y-tex_bmp_rct_pts[0].y)-1)+1,
              srf_bmp_ptr,
              srf_bmp.width,
              color_info,
              inn_wnd_rct);} {$endregion}

      {Actor Blur--------} {$region -fold}
      {clip_mrg:=1;
      SetRectDst;
      SetRectSrc;
      arr_src_sht:=ClippedArr(rect_src,
                              rect_dst,
                              bmp_ftimg_width);
      for i:=0 to 0{sprite_count-1} do
        PPBlur(bmp_color,
               arr_src_sht,
               rect_src,
               rect_dst,
               surf_bmp.width,
               bmp_ftimg_width,
               surf_bmp_handle);} {$endregion}

      {Actor Colorize----} {$region -fold}
      {clip_mrg:=0;
      SetRectDst;
      SetRectSrc;
      arr_src_sht:=ClippedArr(rect_src,
                              rect_dst,
                              bmp_ftimg_width);
      PPColorCorrection1(@ColorizeRMDec,
                         @ColorizeRPDec,
                         bmp_color,
                         arr_src_sht,
                         rect_src,
                         rect_dst,
                         surf_bmp.width,
                         bmp_ftimg_width,
                         surf_bmp_handle,
                         col_trans_var.grayscale_r_val);} {$endregion}

      {Bullets-----------} {$region -fold}
      {begin
        SetColorInfo(clBlue,color_info);
        for i:=0 to 10 do
          begin
            if PointCollDraw(vec_x,
                             vec_y,
                             width,
                             coll_box_arr,
                             inn_wnd_rct,
                             0) then
              begin
                vec_x         -=0{velocity}{d.x-t+Random(t<<1)};
                vec_x_dist_sht:=vec_x-i*distance;
              end
            else
              begin
                vec_x         +=velocity{d.x-t+Random(t<<1)};
                vec_x_dist_sht:=vec_x+i*distance;
              end;
            Point(vec_x_dist_sht,
                  vec_y,
                  srf_bmp_ptr,
                  srf_bmp.width,
                  color_info,
                  inn_wnd_rct);
          end;
        ArrClear(coll_box_arr,inn_wnd_rct,width);
      end;} {$endregion}

      {Fluid Simul.------} {$region -fold}
      {if (sln_pts_cnt>0) then
        begin
          WaterWaveArea(sln_pts,
                        sln_pts_cnt-sln_obj_pts_cnt[sln_obj_cnt-1],
                        sln_pts_cnt);
          SetColorInfo(clRed{clRed},color_info);
          for i:=sln_pts_cnt-sln_obj_pts_cnt[sln_obj_cnt-1] to sln_pts_cnt-2 do
            Line(Trunc(sln_pts[i+0].x),
                 Trunc(sln_pts[i+0].y),
                 Trunc(sln_pts[i+1].x),
                 Trunc(sln_pts[i+1].y),
                 srf_bmp_ptr,
                 srf_bmp.width,
                 color_info,
                 inn_wnd_rct);
          SetColorInfo(clRed{clWhite},color_info);
          for i:=sln_pts_cnt-sln_obj_pts_cnt[sln_obj_cnt-1] to sln_pts_cnt-1 do
            Point(Trunc(sln_pts[i].x),
                  Trunc(sln_pts[i].y),
                  srf_bmp_ptr,
                  srf_bmp.width,
                  color_info,
                  inn_wnd_rct);
        end;} {$endregion}

      {Fluid Colorize----} {$region -fold}
      {PPColorCorrectionP0(@ColorizeBP,
                          srf_bmp_ptr,
                          ClippedRect(inn_wnd_rct,
                                      PtRect(tex_bmp_rct_pts)),
                          srf_bmp.width,
                          SE_Count_X.Value-1);} {$endregion}

      {Fluid Blur--------} {$region -fold}
      {for i:=0 to 0 do
        PPBlur(srf_bmp_ptr,
               inn_wnd_rct,
               srf_bmp.width);}
        {PPMonoNoise(srf_bmp_ptr,
                    inn_wnd_rct,
                    srf_bmp.width,
                    clBlue);} {$endregion}

      {Select Sprites----} {$region -fold}
          (*if IsPointInRect(cur_pos.x,cur_pos.y,inn_wnd_rct) then // if (cur_pos.x>0) and (cur_pos.y>0) then
            begin
              SetRctPos(sprite_rect_arr[useless_fld_arr_[cur_pos.x+cur_pos.y*srf_var.srf_bmp.width]].x,
                        sprite_rect_arr[useless_fld_arr_[cur_pos.x+cur_pos.y*srf_var.srf_bmp.width]].y);

              pix_drw_type:=1;      hdc
              fx_cnt      :=1;

              fx_arr[0].rep_cnt        :=1;

              fx_arr[0].nt_pix_srf_type:=1;
              fx_arr[0].nt_pix_cfx_type:=4;
              fx_arr[0].nt_pix_cng_type:=1;

              fx_arr[0].pt_pix_srf_type:=1;
              fx_arr[0].pt_pix_cfx_type:=4;
              fx_arr[0].pt_pix_cng_type:=1;

              SetRctDst;
              SetRctSrc;
              ShaderType;

              NTValueProc[fx_arr[0].nt_value_proc_ind];
              PTValueProc[fx_arr[0].pt_value_proc_ind];

              pix_drw_type   :=0;

              fx_cnt         :=0;

              nt_pix_srf_type:=1;
              nt_pix_cfx_type:=0;
              nt_pix_cng_type:=0;

              pt_pix_srf_type:=1;
              pt_pix_cfx_type:=0;
              pt_pix_cng_type:=0;
            end;*)

        end; {$endregion}

      {TimeLine Buttons--} {$region -fold}
      {TimeLineButtonsDraw(F_MainForm.S_Splitter2.Top-40,F_MainForm.S_Splitter2.Width>>1-16+4);} {$endregion}

      {Equidistant Curves} {$region -fold}
      {with inn_wnd_rct do
        begin
          //ArrClear(coll_arr,PtRct(left,top,right-1,bottom-1),srf_bmp.width);
          LineBCE3
          (
            sln_pts,
            0,
            sln_pts_cnt-1,
            @coll_arr[0],
            srf_bmp.width,
            PtRct(left,top,right-1,bottom-1),
            PtPos(0,0){world_axis_shift},
            projectile_arr[0].c_rad,
            {True}False
          );
          {ArrFill(coll_arr,
                  srf_bmp_ptr,
                  srf_bmp.width,
                  srf_bmp.height,
                  PtRct(left,top,right-1,bottom-1),
                  clGreen);}
          LineBCE{LineABCE}
          (
            sln_pts,
            0,
            sln_pts_cnt-1,
            srf_bmp_ptr,
            srf_bmp.width,
            color_info,
            PtRct(left,top,right-1,bottom-1),
            world_axis_shift,
            projectile_arr[0].c_rad,
            {True}False
          ); //
        end;} {$endregion}

      {Projectile--------} {$region -fold}
      {projectile_arr_ptr:=Unaligned(@projectile_arr[0]);
      for i:=0 to 0{9999} do
        with projectile_arr_ptr^ do
          begin

            {Proj. Collision Calc.} {$region -fold}
            Projectile(projectile_arr_ptr^,@coll_arr[0],srf_bmp.width,inn_wnd_rct,sln_pts); {$endregion}

            {Proj. Shape Drawing--} {$region -fold}
            CircleHighlight(Trunc(pt_n.x)+world_axis_shift.x,
                            Trunc(pt_n.y)+world_axis_shift.y,
                            low_bmp_ptr,
                            inn_wnd_rct,
                            srf_bmp.width,
                            Default(TColorInfo),
                            c_rad,
                            255);
            CircleC(Trunc(pt_n.x)+world_axis_shift.x,
                    Trunc(pt_n.y)+world_axis_shift.y,
                    c_rad,
                    srf_bmp_ptr,
                    inn_wnd_rct,
                    srf_bmp.width,
                    clBlue);
            {x0:=pt_p.x;
            y0:=pt_p.y;
            x1:=pt_n.x;
            y1:=pt_n.y;
            if LineC(Trunc(x0),
                     Trunc(y0),
                     Trunc(x1),
                     Trunc(y1),
                     inn_wnd_rct) then
              begin

                {n :=8;
                v1:=x1+n*(x1-x0);
                k :=(y1-y0)/(x1-x0);
                b :=(x1*y0-x0*y1)/(x1-x0);
                w1:=k*v1+b;
                SetColorInfo(clPurple,color_info);
                LineAC(Trunc(x0)+world_axis_shift.x,
                       Trunc(y0)+world_axis_shift.y,
                       Trunc(v1)+world_axis_shift.x,
                       Trunc(w1)+world_axis_shift.y,
                       srf_bmp_ptr,
                       srf_bmp.width,
                       color_info,
                       inn_wnd_rct);}
                {SetColorInfo(clBlue,color_info);
                Point(Trunc(pt_p.x)+world_axis_shift.x,
                      Trunc(pt_p.y)+world_axis_shift.y,
                      srf_bmp_ptr,
                      srf_bmp.width,
                      color_info);
                SetColorInfo(clGreen,color_info);
                Point(Trunc(pt_n.x)+world_axis_shift.x,
                      Trunc(pt_n.y)+world_axis_shift.y,
                      srf_bmp_ptr,
                      srf_bmp.width,
                      color_info);
                SetColorInfo(clYellow,color_info);
                Point(Trunc(pt_c.x)+world_axis_shift.x,
                      Trunc(pt_c.y)+world_axis_shift.y,
                      srf_bmp_ptr,
                      srf_bmp.width,
                      color_info);}
              end;} {$endregion}

            Inc(projectile_arr_ptr);
          end;
      with inn_wnd_rct do
        ArrClear(coll_arr,PtRct(left,top,right-1,bottom-1),srf_bmp.width);} {$endregion}

      {World Axis--------} {$region -fold}
      {Inc(drs);
      with world_axis_bmp do
        begin
          if (drs in [0..127]) then
            begin
              pix_drw_type:=02;
              fx_cnt      :=01;
            end
          else
            begin
              pix_drw_type:=00;
              fx_cnt      :=00;
            end;
        end;}

      WorldAxisDraw; {$endregion}

      //if (sln_pts_cnt<>0) and IsRct1InRct2(pts_img_arr[sln_obj_cnt-1].rct_ent,inn_wnd_rct) then
        {begin
          //for i:=0 to 100 do
            {ImgRot2
            (
              PtPos
              (
                pts_img_arr[sln_obj_cnt-1].rct_ent.left{pts_img_arr[sln_obj_cnt-1].rct_ent.left+pts_img_arr[sln_obj_cnt-1].rct_ent.width >>1},
                pts_img_arr[sln_obj_cnt-1].rct_ent.top {pts_img_arr[sln_obj_cnt-1].rct_ent.top +pts_img_arr[sln_obj_cnt-1].rct_ent.height>>1}
              ),
              low_bmp_ptr,
              srf_bmp_ptr,
              low_bmp.width,
              srf_bmp.width,
              PtRct(pts_img_arr[sln_obj_cnt-1].rct_ent),
              inn_wnd_rct,
              angle,
              pts_img_arr[sln_obj_cnt-1].rct_ent.left{200}{-500+{Random}(inn_wnd_rct.width )-pts_img_arr[sln_obj_cnt-1].rct_ent.width >>1}, //Random(2000)-1000,
              pts_img_arr[sln_obj_cnt-1].rct_ent.top {200}{-500+{Random}(inn_wnd_rct.height)-pts_img_arr[sln_obj_cnt-1].rct_ent.height>>1}, //Random(2000)-1000,
              1,
              low_bmp.height
            );}
          for i:=0 to 0{1300} do
          {ImgRot2
            (
              PtPos
              (
                tex_bmp.width >>1,
                tex_bmp.height>>1
              ),
              tex_bmp_ptr,
              srf_bmp_ptr,
              tex_bmp.width,
              srf_bmp.width,
              PtRct(0,0,tex_bmp.width,tex_bmp.height),
              inn_wnd_rct,
              angle,
              cur_pos.x,
              cur_pos.y,
              1,
              tex_bmp.height
            );}
          ImgRot1
            (
              PtPos
              (
                tex_bmp.width >>1,
                tex_bmp.height>>1
              ),
              tex_bmp_ptr,  //
              srf_bmp_ptr,
              tex_bmp.width,
              srf_bmp.width,
              PtRct(0,0,tex_bmp.width,tex_bmp.height),
              inn_wnd_rct,
              angle,
              cur_pos.x-tex_bmp.width >>1,
              cur_pos.y-tex_bmp.height>>1,
              False,

            );
          //angle:=37;
          angle+=1{1};
          if (angle>=360) then
            angle:=0;
        end;}

      SetColorInfo(clBlue,color_info);
      Point(main_char_pos.x,
            main_char_pos.y,
            srf_bmp_ptr,
            srf_bmp.width,
            color_info,
            inn_wnd_rct);

      {Cursor------------} {$region -fold}
      //CircleC(cur_pos.x,cur_pos.y,crc_rad,srf_bmp_ptr,inn_wnd_rct,srf_bmp.width,clBlue);
      CursorDraw(cur_pos.x,cur_pos.y);
      CircleHighlight(cur_pos.x,
                      cur_pos.y,
                      srf_bmp_ptr,
                      inn_wnd_rct,
                      srf_bmp.width,
                      Default(TColorInfo),
                      128,
                      045); {$endregion}

      {Minimap-----------} {$region -fold}
      {ITScl(srf_bmp_ptr,srf_bmp_ptr,low_bmp.width,low_bmp.height,6,6);} {$endregion}

      {Full Scene Drawing} {$region -fold}
      //CnvToCnv(srf_bmp_rct,Canvas,srf_bmp.Canvas,SRCCOPY);
      //glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
      //glLoadIdentity;
      with srf_var do
        begin
          //glDrawPixels(srf_bmp.Width,srf_bmp.Height,32993{swap channels: GL_RGBA=$1908 to GL_BGRA=32993},GL_UNSIGNED_BYTE,{srf_bmp_ptr}buffer.bmBits);
          glEnable       (GL_TEXTURE_2D);
          glTexImage2D   (GL_TEXTURE_2D,0,3,srf_bmp.Width,srf_bmp.Height,0,32993{swap channels: GL_RGBA=$1908 to GL_BGRA=32993},GL_UNSIGNED_BYTE,buffer.bmBits);
          glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST{GL_LINEAR});
          {glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST{GL_LINEAR});
          glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S    ,GL_CLAMP  {GL_REPEAT});
          glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T    ,GL_CLAMP  {GL_REPEAT});}
          {glEnable       (GL_COLOR_LOGIC_OP);
          glLogicOp      (GL_COPY_INVERTED);}
          {glEnable       (GL_BLEND);
          glBlendFunc    (GL_ONE_MINUS_DST_COLOR,GL_ZERO);}
          glBegin        (GL_QUADS);
            glTexCoord2f ( 0, 0  );
            glVertex3f   (-1, 1,0);
            glTexCoord2f ( 1, 0  );
            glVertex3f   ( 1, 1,0);
            glTexCoord2f ( 1, 1  );
            glVertex3f   ( 1,-1,0);
            glTexCoord2f ( 0, 1  );
            glVertex3f   (-1,-1,0);
          glEnd;
        end;
      OpenGLControl2.SwapBuffers; {$endregion}

    end;

end; {$endregion}
procedure TF_MainForm.T_Logo1Timer    (sender:TObject);                   {$region -fold}
begin
  with srf_var do
    begin
      PPFloodFill(srf_bmp_ptr,inn_wnd_rct,srf_bmp.width,bg_color);
      with logo1_img do
        begin
          FadeTemplate0(100,100,100,col_trans_arr[02],time_interval);
          if (time_interval=0) then
            begin
              T_Logo1.Enabled:=False;
              T_Logo2.Enabled:=True;
              mciSendString(PChar('play "'+LOGO2_MUSIC+'"'),nil,0,0);
            end;
          SetBkgnd (srf_bmp_ptr,
                    srf_bmp.width,
                    srf_bmp.height);
          SetClpRct(inn_wnd_rct);
          SetRctPos(world_axis.x+world_axis_shift.x-logo1_img.bmp_ftimg_width >>1,
                    world_axis.y+world_axis_shift.y-logo1_img.bmp_ftimg_height>>1);
          SdrProc[3];
        end;
      //GetCursorPos(cur_pos);
      //cur_pos:=ScreenToClient(cur_pos);
      //CursorDraw(cur_pos.x,cur_pos.y);
      glEnable       (GL_TEXTURE_2D);
      glTexImage2D   (GL_TEXTURE_2D,0,3,srf_bmp.Width,srf_bmp.Height,0,32993,GL_UNSIGNED_BYTE,buffer.bmBits);
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
      glBegin        (GL_QUADS);
        glTexCoord2f ( 0, 0  );
        glVertex3f   (-1, 1,0);
        glTexCoord2f ( 1, 0  );
        glVertex3f   ( 1, 1,0);
        glTexCoord2f ( 1, 1  );
        glVertex3f   ( 1,-1,0);
        glTexCoord2f ( 0, 1  );
        glVertex3f   (-1,-1,0);
      glEnd;
    end;
  OpenGLControl2.SwapBuffers;
end; {$endregion}
procedure TF_MainForm.T_Logo2Timer    (sender:TObject);                   {$region -fold}
begin
  with srf_var do
    begin
      PPFloodFill(srf_bmp_ptr,inn_wnd_rct,srf_bmp.width,bg_color);
      with logo2_img do
        begin
          FadeTemplate1(100,100,100,col_trans_arr[02],time_interval);
          if (time_interval=0) then
            begin
              T_Logo2.Enabled       :=False;
              T_Logo3.Enabled       :=True;
              mciSendString(PChar('stop "'+LOGO2_MUSIC+'"'),nil,0,0);
              LCLVLCPlayer_Intro.PlayFile(Application.Location+INTRO_MOVIE);
            end;
          SetBkgnd (srf_bmp_ptr,
                    srf_bmp.width,
                    srf_bmp.height);
          SetClpRct(inn_wnd_rct);
          SetRctPos(world_axis.x+world_axis_shift.x-logo2_img.bmp_ftimg_width >>1,
                    world_axis.y+world_axis_shift.y-logo2_img.bmp_ftimg_height>>1);
          SdrProc[3];
        end;
      //GetCursorPos(cur_pos);
      //cur_pos:=ScreenToClient(cur_pos);
      //CursorDraw(cur_pos.x,cur_pos.y);
      glEnable       (GL_TEXTURE_2D);
      glTexImage2D   (GL_TEXTURE_2D,0,3,srf_bmp.Width,srf_bmp.Height,0,32993,GL_UNSIGNED_BYTE,buffer.bmBits);
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
      glBegin        (GL_QUADS);
        glTexCoord2f ( 0, 0  );
        glVertex3f   (-1, 1,0);
        glTexCoord2f ( 1, 0  );
        glVertex3f   ( 1, 1,0);
        glTexCoord2f ( 1, 1  );
        glVertex3f   ( 1,-1,0);
        glTexCoord2f ( 0, 1  );
        glVertex3f   (-1,-1,0);
      glEnd;
    end;
  OpenGLControl2.SwapBuffers;
end; {$endregion}
procedure TF_MainForm.T_Logo3Timer    (sender:TObject);                   {$region -fold}
begin
  time_interval+=1;
  case time_interval of
    0          :
      begin
        T_Logo3.Enabled:=False;
        T_Menu.Enabled :=True;
        LCLVLCPlayer_Intro.Stop;
        mciSendString(PChar('stop "'+DUCK_VOICE1+'"'),nil,0,0);
        mciSendString(PChar('play "'+MENU_THEME +'"'),nil,0,0);
      end;
    1,10,50,060: PlaySound    (PChar(EGG_SHAKE               ),0,SND_ASYNC);
            080: mciSendString(PChar('play "'+DUCK_VOICE1+'"'),nil,0,0    );
            090: PlaySound    (PChar(EGG_EXPLOSION           ),0,SND_ASYNC);
            210: PlaySound    (PChar(LETTERS_DROP            ),0,SND_ASYNC);
            380: time_interval:=-1;
  end;
end; {$endregion}
procedure TF_MainForm.T_MenuTimer     (sender:TObject);                   {$region -fold}
begin
  with srf_var do
    begin
      PPFloodFill(srf_bmp_ptr,inn_wnd_rct,srf_bmp.width,bg_color,flood_fill_inc);
      flood_fill_inc:=not flood_fill_inc;
      with start_game_img do
        begin
          SetBkgnd (srf_bmp_ptr,
                    srf_bmp.width,
                    srf_bmp.height);
          SetClpRct(inn_wnd_rct);
          SetRctPos(world_axis.x+world_axis_shift.x-start_game_img.bmp_ftimg_width >>1,
                    world_axis.y+world_axis_shift.y-start_game_img.bmp_ftimg_height>>1-70);
          SdrProc[3];
        end;
      with settings_img do
        begin
          SetBkgnd (srf_bmp_ptr,
                    srf_bmp.width,
                    srf_bmp.height);
          SetClpRct(inn_wnd_rct);
          SetRctPos(world_axis.x+world_axis_shift.x-settings_img.bmp_ftimg_width >>1,
                    world_axis.y+world_axis_shift.y-settings_img.bmp_ftimg_height>>1-70+60);
          SdrProc[3];
        end;
      with save_and_exit_img do
        begin
          SetBkgnd (srf_bmp_ptr,
                    srf_bmp.width,
                    srf_bmp.height);
          SetClpRct(inn_wnd_rct);
          SetRctPos(world_axis.x+world_axis_shift.x-save_and_exit_img.bmp_ftimg_width >>1,
                    world_axis.y+world_axis_shift.y-save_and_exit_img.bmp_ftimg_height>>1-70+120);
          SdrProc[3];
        end;
      with selection_border_img do
        begin
          SetBkgnd (srf_bmp_ptr,
                    srf_bmp.width,
                    srf_bmp.height);
          SetClpRct(inn_wnd_rct);
          SetRctPos(world_axis.x+world_axis_shift.x-selection_border_img.bmp_ftimg_width >>1,
                    world_axis.y+world_axis_shift.y-selection_border_img.bmp_ftimg_height>>1-70+60*menu_img_arr_cnt);
          SdrProc[3];
        end;
      with military_head_img do
        begin
          SetBkgnd (srf_bmp_ptr,
                    srf_bmp.width,
                    srf_bmp.height);
          SetClpRct(inn_wnd_rct);
          SetRctPos(world_axis.x+world_axis_shift.x-selection_border_img.bmp_ftimg_width >>1-military_head_img.bmp_ftimg_width-20,
                    world_axis.y+world_axis_shift.y-military_head_img   .bmp_ftimg_height>>1-70+60*menu_img_arr_cnt);
          SdrProc[3];
        end;
      with menu_img_arr[menu_img_arr_cnt] do
        begin
          begin
            pix_drw_type     :=001;
            col_trans_arr[04]:=032;
            fx_cnt           :=001;
            fx_arr[0].rep_cnt        :=01;
            fx_arr[0].nt_pix_srf_type:=01;
            fx_arr[0].nt_pix_cfx_type:=04;
            fx_arr[0].nt_pix_cng_type:=00;
            fx_arr[0].pt_pix_srf_type:=01;
            fx_arr[0].pt_pix_cfx_type:=04;
            fx_arr[0].pt_pix_cng_type:=00;
          end;
          SetBkgnd (srf_bmp_ptr,
                    srf_bmp.width,
                    srf_bmp.height);
          SetClpRct(inn_wnd_rct);
          SetRctPos(world_axis.x+world_axis_shift.x-menu_img_arr[menu_img_arr_cnt].bmp_ftimg_width >>1,
                    world_axis.y+world_axis_shift.y-menu_img_arr[menu_img_arr_cnt].bmp_ftimg_height>>1-70+60*menu_img_arr_cnt);
          SdrProc[3];
          begin
            pix_drw_type:=000;
            fx_cnt      :=000;
          end;
        end;
      //GetCursorPos(cur_pos);
      //cur_pos:=ScreenToClient(cur_pos);
      //CursorDraw(cur_pos.x,cur_pos.y);
      glEnable       (GL_TEXTURE_2D);
      glTexImage2D   (GL_TEXTURE_2D,0,3,srf_bmp.Width,srf_bmp.Height,0,32993,GL_UNSIGNED_BYTE,buffer.bmBits);
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
      glBegin        (GL_QUADS);
        glTexCoord2f ( 0, 0  );
        glVertex3f   (-1, 1,0);
        glTexCoord2f ( 1, 0  );
        glVertex3f   ( 1, 1,0);
        glTexCoord2f ( 1, 1  );
        glVertex3f   ( 1,-1,0);
        glTexCoord2f ( 0, 1  );
        glVertex3f   (-1,-1,0);
      glEnd;
    end;
  OpenGLControl2.SwapBuffers;
end; {$endregion}
procedure TF_MainForm.T_GameTimer     (sender:TObject);                   {$region -fold}
var
  color_info: TColorInfo;
  i         : integer;
begin
  with srf_var do
    begin
      PPFloodFill(srf_bmp_ptr,inn_wnd_rct,srf_bmp.width,bg_color,flood_fill_inc);
      flood_fill_inc:=not flood_fill_inc;
      //WorldAxisDraw;
      with tlm_var do
        for i:=0 to High(tilemap_arr2) do
          with tilemap_arr2[i{High(mask_template_arr2)}] do
            begin
              SetRctPos(world_axis.x-(bmp_ftimg_width_origin *tilemap_sprite_w_h.x)>>1+srf_var.world_axis_shift.x,
                        world_axis.y-(bmp_ftimg_height_origin*tilemap_sprite_w_h.y)>>1+srf_var.world_axis_shift.y);
              SetBkgnd
              (
                srf_bmp_ptr,
                srf_bmp.width,
                srf_bmp.height
              );
              with tilemap_sprite_ptr^ do
                SetBkgnd
                (
                  srf_bmp_ptr,
                  srf_bmp.width,
                  srf_bmp.height
                );
              FilMaskTemplate1;
              FilMaskTemplate2;
              bmp_bkgnd_ptr:=@coll_arr[0];
            end;
      SetColorInfo(clBlue,color_info);
      Point(main_char_pos.x,
            main_char_pos.y,
            srf_bmp_ptr,
            srf_bmp.width,
            color_info,
            inn_wnd_rct);
      GetCursorPos(cur_pos);
      cur_pos:=ScreenToClient(cur_pos);
      CursorDraw(cur_pos.x,cur_pos.y);
      glEnable       (GL_TEXTURE_2D);
      glTexImage2D   (GL_TEXTURE_2D,0,3,srf_bmp.Width,srf_bmp.Height,0,32993,GL_UNSIGNED_BYTE,buffer.bmBits);
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
      glBegin        (GL_QUADS);
        glTexCoord2f ( 0, 0  );
        glVertex3f   (-1, 1,0);
        glTexCoord2f ( 1, 0  );
        glVertex3f   ( 1, 1,0);
        glTexCoord2f ( 1, 1  );
        glVertex3f   ( 1,-1,0);
        glTexCoord2f ( 0, 1  );
        glVertex3f   (-1,-1,0);
      glEnd;
    end;
  OpenGLControl2.SwapBuffers;
end; {$endregion}
{$endregion}

// (Test) Тест:
{UI} {$region -fold}
procedure TF_MainForm.Button1Click(sender:TObject); {$region -fold}
var
  c,s,v,w       : double;
  execution_time: double;
  i,i_          : integer;
  color_info    : TColorInfo;
  b             : boolean;
  rot_img       : TFastImage;
  tex_img       : TFastImage;

  procedure BakeRot(var rot_img_:TFastImage; constref angle_:double);
  begin
    with srf_var,tex_var do
      begin
        if (Trunc(angle_)=0) then
          begin
            rot_img_:=Nil;
            Exit;
          end;
        ImgRot1
        (
          PtPos
          (
            tex_bmp.width >>1,
            tex_bmp.height>>1
          ),
          PtRct(0,0,tex_bmp.width,tex_bmp.height),
          inn_wnd_rct,
          tex_bmp_ptr,
          rot_arr_ptr,
          tex_bmp.width,
          srf_bmp.width,
          angle_,
          world_axis.x+world_axis_shift.x-tex_bmp.width >>1,
          world_axis.y+world_axis_shift.y-tex_bmp.height>>1,
          1,
          bounding_rct,
          NT_BIT_MASK_ALPHA
        );
        BorderBlur(rot_arr_ptr,srf_bmp.width,inn_wnd_rct,0,NT_BIT_MASK_ALPHA);
        ImgRot1
        (
          PtPos
          (
            tex_bmp.width >>1,
            tex_bmp.height>>1
          ),
          PtRct(0,0,tex_bmp.width,tex_bmp.height),
          inn_wnd_rct,
          tex_bmp_ptr,
          rot_arr_ptr,
          tex_bmp.width,
          srf_bmp.width,
          angle_,
          world_axis.x+world_axis_shift.x-tex_bmp.width >>1,
          world_axis.y+world_axis_shift.y-tex_bmp.height>>1,
          1,
          bounding_rct,
          0
        );
        if (Trunc(angle_) mod 360=0) then
          begin
            rot_img_:=Nil;
            Exit;
          end;
        rot_img_:=TFastImage.Create
        (
          rot_arr_ptr,
          srf_bmp.width,
          srf_bmp.height,
          inn_wnd_rct,
          bounding_rct,
          0
        );
        with rot_img_ do
          begin
            SetRctPos (bounding_rct.left,bounding_rct.top);
            SetValInfo(rot_arr_ptr,Nil,Nil,srf_bmp.width,srf_bmp.height);
            bmp_src_rct_clp:=bounding_rct;
            img_kind       :=1;
            pix_drw_type   :=0;   //must be in range of [0..002]
            fx_cnt         :=0;   //must be in range of [0..255]
            alpha_max      :=$FF; //$7F;
            CmpProc[img_kind];    //ImgToCImg;
            SetRctPos(bmp_src_rct_clp);
            SetSdrType;
            ShaderType;
          end;
        ArrClear(rot_arr_ptr,inn_wnd_rct,rot_arr_width,0,False);
      end;
  end;

  procedure DrawRot(    rot_img_:TFastImage; constref angle_:double);
  begin
    with srf_var,tex_var do
      ImgRot1
      (
        PtPos
        (
          tex_bmp.width >>1,
          tex_bmp.height>>1
        ),
        PtRct(0,0,tex_bmp.width,tex_bmp.height),
        inn_wnd_rct,
        tex_bmp_ptr,
        srf_bmp_ptr,
        tex_bmp.width,
        srf_bmp.width,
        angle_,
        world_axis.x+world_axis_shift.x-tex_bmp.width >>1,
        world_axis.y+world_axis_shift.y-tex_bmp.height>>1,
        0,
        bounding_rct,
        0
      );
    if (rot_img_<>Nil) then
      with rot_img_ do
        begin
          SetBkgnd
          (
            srf_var.srf_bmp_ptr,
            srf_var.srf_bmp.width,
            srf_var.srf_bmp.height
          );
          SetRctPos(bounding_rct.left,bounding_rct.top);
          SdrProc[3];
        end;
  end;

  function CalcPix: integer;
  var
    i: integer;
  begin
    Result:=0;
    for i:=0 to angle_cnt-1 do
      if (rot_img_arr[i]<>Nil) then
        Result+=rot_img_arr[i].nt_pix_cnt;
  end;

begin
  {
  {angle    :=0{45};
  angle_cnt:=361{0};
  loop_cnt :=1{000}{00000};
  SetLength(rot_img_arr,angle_cnt);

  with tex_var do
    if show_tex then
      begin
        tex_bmp_ptr:=GetBmpHandle(tex_bmp );
        tex_bmp.Canvas.Draw(0,0,loaded_picture.Bitmap);
      end;

  PPFloodFill(srf_var.srf_bmp_ptr,bounding_rct,srf_var.srf_bmp.width,srf_var.bg_color);
  exec_timer:=TPerformanceTime.Create;
  exec_timer.Start;

  with srf_var do
    tex_img:=TFastImage.Create
    (
      rot_arr_ptr,
      srf_bmp.width,
      srf_bmp.height,
      inn_wnd_rct,
      bounding_rct,
      0
    );

  with tex_var,tex_img do
    begin
      SetValInfo (tex_bmp_ptr,Nil,Nil,tex_bmp.width,tex_bmp.height);
      //CrtTBmpInst(loaded_picture.Bitmap,bmp_color_ptr);
      bmp_src_rct_clp:=PtRct(0,0,tex_bmp.width,tex_bmp.height);
      ImgToCImg;
    end;

  for i:=0 to angle_cnt-1 do
    BakeRot(rot_img_arr[i],angle+i);

  exec_timer.Stop;
  execution_time:=Trunc(exec_timer.Delay*1000);

  Sleep(1000);}
  //for i:=0 to (angle_cnt-1)*2{-1} do
    begin
      {Sleep(10);
      PPFloodFill(srf_var.srf_bmp_ptr,srf_var.inn_wnd_rct{bounding_rct},srf_var.srf_bmp.width,srf_var.bg_color);
      with tex_img do
        begin
          SetBckgd
          (
            srf_var.srf_bmp_ptr,
            srf_var.srf_bmp.width,
            srf_var.srf_bmp.height
          );
          SetRctPos(100,100);
          SdrProc[3];
        end;
      i_:=i mod 360;
      DrawRot(rot_img_arr[i_],angle+i_);}

      EdgeAATest(srf_var.srf_bmp_ptr,srf_var.inn_wnd_rct,srf_var.srf_bmp.width,100,10{StrToInt(Memo1.Lines.Text)});

      CnvToCnv(srf_var.srf_bmp_rct,Canvas,srf_var.srf_bmp.Canvas,SRCCOPY);
      InvalidateInnerWindow;
      Application.ProcessMessages;
    end;

  {with srf_var do
    begin
      //Sleep(10);
      EdgeAATest(srf_bmp_ptr,inn_wnd_rct,srf_bmp.width,StrToInt(Memo1.Lines.Text));
      CnvToCnv(srf_var.srf_bmp_rct,Canvas,srf_var.srf_bmp.Canvas,SRCCOPY);
      InvalidateInnerWindow;
    end;}

  {with srf_var,tex_var,tex_img do
    Memo1.Lines.Text:='pix count         :'+IntToStr  (CalcPix         )+' px.'+#13+
                      'Execution time    :'+FloatToStr(execution_time  )+' ms.'+#13+
                      'img kind          :'+IntToStr  ((bmp_color_ptr+54)^>>24)+' px.';
                     {'loop count        :'+IntToStr  (loop_cnt      )       +#13+
                      'destination width :'+IntToStr  (srf_bmp.width )+' px.'+#13+
                      'destination height:'+IntToStr  (srf_bmp.height)+' px.'+#13+
                      'image width       :'+IntToStr  (tex_bmp.width )+' px.'+#13+
                      'image height      :'+IntToStr  (tex_bmp.height)+' px.'+#13};}


  {
  with srf_var do
    begin

      SetColorInfo(clBlue,color_info);
      Point(world_axis.x,
            world_axis.y,
            srf_bmp_ptr,
            srf_bmp.width,
            color_info); // pivot;

      SetColorInfo(clGreen,color_info);
      for i:=0 to 360 do
        begin
          GetRotNotRound(PtPos(10,10),i,c,s,v,w,100,100);
          Point(Trunc(v+world_axis.x),
                Trunc(w+world_axis.y),
                srf_bmp_ptr,
                srf_bmp.width,
                color_info,
                inn_wnd_rct); // turned points cloud;
        end;

      SetColorInfo(clRed,color_info);
      for i:=0 to 360 do
        begin
          GetRotRound(PtPos(10,10),i,c,s,v,w,100,100);
          Point(Trunc(v+world_axis.x),
                Trunc(w+world_axis.y),
                srf_bmp_ptr,
                srf_bmp.width,
                color_info,
                inn_wnd_rct); // turned points cloud;
        end;

      SetColorInfo(clBlack,color_info);
      for i:=0 to 360 do
        begin
          GetRotNotRound2(PtPos(10,10),i,c2,s2,v2,w2,100,100);
          Point(v2+world_axis.x,
                w2+world_axis.y,
                srf_bmp_ptr,
                srf_bmp.width,
                color_info,
                inn_wnd_rct); // turned points cloud;
        end;

      CnvToCnv(srf_bmp_rct,Canvas,srf_bmp.Canvas,SRCCOPY);
      InvalidateInnerWindow;

    end;
  }

  }
  //
  Memo1.Lines.Text:='';
  SetLength(arr_test,10000000);
  for i:=0 to 10000000-1 do
    arr_test[i]:=Random(2);

  {for i:=0 to 5000000-1 do
    arr_test[i]:=1;
  for i:=5000000 to 10000000-1 do
    arr_test[i]:=0;}
  {for i:=0 to 5000000-1 do
    arr_test[2*i]:=0;
  for i:=0 to 5000000-1 do
    arr_test[2*i+1]:=1;}

  exec_timer:=TPerformanceTime.Create;
  exec_timer.Start;

  ArrNzItCnt(arr_test);

  exec_timer.Stop;
  execution_time:=Trunc(exec_timer.Delay*1000);
  Memo1.Lines.Text:=FloatToStr(execution_time);

end; {$endregion}
{$endregion}

end.

initialization

{$I main.lrs}

end.
