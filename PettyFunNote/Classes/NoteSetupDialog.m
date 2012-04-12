    //
//  NoteSetupPanel.m
//  PettyFunNote
//
//  Created by YJ Park on 12/2/10.
//  Copyright 2010 PettyFun. All rights reserved.
//

#import "NoteSetupDialog.h"
#import "PFNoteModel.h"
#import "PFNotePainterFactory.h"

@implementation NoteSetupDialog
@synthesize delegate;

-(void)dealloc {
    [savedConfig release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSliders];
    PF_L10N_VIEW(101, @"setup_theme_title");
    PF_L10N_VIEW(201, @"setup_line_style_title");
    PF_L10N_VIEW(1301, @"setup_margins_title");
    PF_L10N_VIEW(411, @"setup_margin_left_right");
    PF_L10N_VIEW(412, @"setup_margin_top_bottom");
    PF_L10N_VIEW(413, @"setup_margin_line");
    PF_L10N_VIEW(414, @"setup_margin_word");
    PF_L10N_VIEW(415, @"setup_margin_indent");
    PF_L10N_VIEW(416, @"setup_margin_space");
    PF_L10N_VIEW(501, @"setup_save_as_default");
    PF_L10N_VIEW(502, @"setup_save");
    PF_L10N_VIEW(503, @"cancel");
    [gridTypeControl setTitle:PF_L10N(@"setup_grid_blank") forSegmentAtIndex:0];
    [gridTypeControl setTitle:PF_L10N(@"setup_grid_line") forSegmentAtIndex:1];
    [gridTypeControl setTitle:PF_L10N(@"setup_grid_box") forSegmentAtIndex:2];
    [gridTypeControl setTitle:PF_L10N(@"setup_grid_grid") forSegmentAtIndex:3];
    PF_L10N_VIEW(601, @"setup_effects_title");
    [strokeTypeControl setTitle:PF_L10N(@"setup_effect_none") forSegmentAtIndex:0];
    [strokeTypeControl setTitle:PF_L10N(@"setup_effect_pop") forSegmentAtIndex:1];
    
    themesTable.separatorColor = PFNOTE_POPUP_TABLE_SEPARATOR_COLOR;

    UIColor *backgroundColor = PFNOTE_POPUP_BACKGROUDCOLOR;

    self.view.backgroundColor = backgroundColor;
    backgroundColor = [UIColor clearColor];
    PF_SET_VIEW_BACKGROUNDCOLOR(99, backgroundColor);
    PF_SET_VIEW_BACKGROUNDCOLOR(98, backgroundColor);
    themesTable.backgroundColor = backgroundColor;
    leftRightSlider.backgroundColor = backgroundColor;
    topBottomSlider.backgroundColor = backgroundColor;
    lineSlider.backgroundColor = backgroundColor;
    wordSlider.backgroundColor = backgroundColor;
    indentSlider.backgroundColor = backgroundColor;
    spaceSlider.backgroundColor = backgroundColor;
    
    UIColor *textColor = PFNOTE_POPUP_TEXTCOLOR;
    PF_SET_LABEL_TEXTCOLOR(101, textColor)
    PF_SET_LABEL_TEXTCOLOR(201, textColor)
    PF_SET_LABEL_TEXTCOLOR(1301, textColor)
    PF_SET_LABEL_TEXTCOLOR(411, textColor)
    PF_SET_LABEL_TEXTCOLOR(412, textColor)
    PF_SET_LABEL_TEXTCOLOR(413, textColor)
    PF_SET_LABEL_TEXTCOLOR(414, textColor)
    PF_SET_LABEL_TEXTCOLOR(415, textColor)
    PF_SET_LABEL_TEXTCOLOR(416, textColor)    
    PF_SET_LABEL_TEXTCOLOR(601, textColor)
    
    DECLARE_PFUTILS
    [utils setupBlueButton:self.view tag:501];
    [utils setupBlueButton:self.view tag:502];
    [utils setupBlueButton:self.view tag:503];
    
    //iPhone hacks
    if ([self.view viewWithTag:1001]) {
        UIScrollView *scrollView = (UIScrollView *)[self.view viewWithTag:1001];
        scrollView.contentSize = CGSizeMake(240, 460);
    }
}

- (void)releaseViewElements {
    [super releaseViewElements];
    PF_Release_IBOutlet(strokeTypeControl)
    PF_Release_IBOutlet(gridTypeControl)
    PF_Release_IBOutlet(themesTable)
    PF_Release_IBOutlet(gridColorsView)
    PF_Release_IBOutlet(gridColorSelectedIcon)
    PF_Release_IBOutlet(themeSelectedIcon)
    PF_Release_IBOutlet(leftRightSlider)
    PF_Release_IBOutlet(topBottomSlider)
    PF_Release_IBOutlet(lineSlider)
    PF_Release_IBOutlet(wordSlider)
    PF_Release_IBOutlet(indentSlider)
    PF_Release_IBOutlet(spaceSlider)
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DECLARE_PFNOTE_MODEL
        
    //deal with config
    if (savedConfig) {
        [savedConfig release];
    }
    savedConfig = [model.config copyWithZone:nil];
    
    //update stroke type
    NSString *strokeType = [model.config getStrokeType];
    if ([strokeType isEqualToString:PFNOTE_POP_STROKE]) {
        strokeTypeControl.selectedSegmentIndex = 1;
    } else {
        strokeTypeControl.selectedSegmentIndex = 0;
    }
    [self updateSpecialEffectsTitle];
    
    //update grid state
    NSString *gridType = [model.config getGridType];
    if ([gridType isEqualToString:PFNOTE_LINE_GRID_PAINTER]) {
        gridTypeControl.selectedSegmentIndex = 1;
    } else if ([gridType isEqualToString:PFNOTE_BOX_GRID_PAINTER]) {
        gridTypeControl.selectedSegmentIndex = 2;
    } else if ([gridType isEqualToString:PFNOTE_CROSS_GRID_PAINTER]) {
        gridTypeControl.selectedSegmentIndex = 3;
    } else {
        gridTypeControl.selectedSegmentIndex = 0;
    }
    
    //update grid colors
    [self updateGridColors];
    [self updateSliders];
    [themesTable reloadData];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    DECLARE_PFNOTE_MODEL
    if (savedConfig) {
        [model.config updateTo:savedConfig];
        [model refreshConfig];
        [self updateConfig:YES];
    }
    [self resetSliders];
    if (delegate) {
        [delegate onSetupDialogFinished];
    }
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    DECLARE_PFNOTE_MODEL
    return [model shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

#pragma mark -
#pragma mark Tableview datasource
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PFUTILS_delayWithInterval(PFNOTE_SETUP_SELECT_BACKGROUND_DELAY, nil, selectCurrentTheme:)
    DECLARE_PFNOTE_PAINTER_FACTORY
    return [painterFactory.themeList count];
}

-(void) selectCurrentTheme:(NSTimer *)timer {
    DECLARE_PFNOTE_MODEL
    DECLARE_PFNOTE_PAINTER_FACTORY
    NSInteger index = [painterFactory.themeList indexOfObject:model.config.themeType];
    if (index >= 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [themesTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:YES];
    }    
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"BackgroundPainterCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.image = themeSelectedIcon.image;
        cell.imageView.highlightedImage = themeSelectedIcon.highlightedImage;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
	// Configure the cell.
    DECLARE_PFNOTE_PAINTER_FACTORY
	NSString *themeType = [painterFactory.themeList objectAtIndex:indexPath.row];
    NSString *title = PF_L10N_(NSFormat(@"product_%@_%@_name", PFNoteProductTypeTheme, themeType), themeType);
    cell.textLabel.text = title;
    
    DECLARE_PFNOTE_MODEL
    if ([model hadPurchased:themeType withType:PFNoteProductTypeTheme]) {
        cell.detailTextLabel.text = @"";
    } else {
        cell.detailTextLabel.text = PF_L10N(@"product_try");
    }
    
    return cell;
}

#pragma mark -
#pragma mark Tableview delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	// Configure the cell, cann't remember why, though have to do this here.
	int row = [indexPath row];
    DECLARE_PFNOTE_PAINTER_FACTORY
	NSString *themeType = [painterFactory.themeList objectAtIndex:row];
    PFNoteTheme *theme = [painterFactory getThemeByType:themeType];
    if (theme) {
        cell.backgroundColor = [theme getPreviewColor];
        //has to set text background here, otherwise the label is showing
        //some wrong border.
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        cell.textLabel.textColor = [theme getTextColor];
        cell.detailTextLabel.textColor = [theme getColor:1];
    }
    DECLARE_PFNOTE_MODEL
    if ([themeType isEqualToString:model.config.themeType]) {
        cell.imageView.highlighted = YES;
    } else {
        cell.imageView.highlighted = NO;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].imageView.highlighted = NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].imageView.highlighted = YES;

    DECLARE_PFNOTE_PAINTER_FACTORY
	NSString *themeType = [painterFactory.themeList objectAtIndex:indexPath.row];
    DECLARE_PFNOTE_MODEL
    model.config.themeType = themeType;
    [model refreshConfig];
    [self updateGridColors];
    
    [self updateConfig:YES];
}

#pragma mark -
#pragma mark Specific Methods

-(void) updateGridColors {
    DECLARE_PFNOTE_PAINTER_FACTORY
    DECLARE_PFNOTE_MODEL
    PFNoteTheme *theme = [painterFactory getTheme:model.config];
    for (int i = 0; i < PFNOTE_SETUP_GRID_COLOR_TAG_NUM; i++) {
        int tag = PFNOTE_SETUP_GRID_COLOR_TAG_START + i;
        UIView *gridColorButton = [gridColorsView viewWithTag:tag];
        if (gridColorButton) {
            gridColorButton.backgroundColor = [theme getGridColor:i];
        }
    }
    [self updateGridColorSelectedIcon];
}

-(void) updateGridColorSelectedIcon {
    DECLARE_PFNOTE_MODEL
    NSInteger gridColorIndex = [model.config getGridColorIndex];
    int tag = PFNOTE_SETUP_GRID_COLOR_TAG_START + gridColorIndex;
    UIView *gridColorButton = [gridColorsView viewWithTag:tag];
    if (gridColorButton) {
        gridColorSelectedIcon.frame = CGRectMake(
            gridColorButton.frame.origin.x + gridColorButton.frame.size.width - gridColorSelectedIcon.frame.size.width,
            gridColorButton.frame.origin.y + gridColorButton.frame.size.height - gridColorSelectedIcon.frame.size.height,
            gridColorSelectedIcon.frame.size.width,
            gridColorSelectedIcon.frame.size.height);
        gridColorSelectedIcon.hidden = NO;
    } else {
        gridColorSelectedIcon.hidden = YES;
    }
}

-(IBAction) onSaveAsDefault:(id)sender {
    if (delegate) {
        [delegate onSetupDialogSave:YES];
    }
}

-(IBAction) onSave:(id)sender {
    [savedConfig release];
    savedConfig = nil;
    if (delegate) {
        [delegate onSetupDialogSave:NO];
    }
}

-(void) updateSpecialEffectsTitle {
    DECLARE_PFNOTE_MODEL
    NSString *strokeType = [model.config getStrokeType];
    if (strokeType && ![model hadPurchased:strokeType withType:PFNoteProductTypeStroke]) {
        PF_L10N_VIEW(601, @"setup_effects_title_try");
    } else {
        PF_L10N_VIEW(601, @"setup_effects_title");
    }
}

-(IBAction) onStrokeTypeChanged:(id)sender {
    NSString *strokeType = nil;
    switch (strokeTypeControl.selectedSegmentIndex) {
        case 1:
            strokeType = PFNOTE_POP_STROKE;
            break;
        default:
            break;
    }
    DECLARE_PFNOTE_MODEL
    [model.config setStrokeType:strokeType];
    [model clearCellCache];
    [self updateSpecialEffectsTitle];
    [self updateConfig:NO];    
}
         
-(IBAction) onGridTypeChanged:(id)sender {
    NSString *gridType = nil;
    switch (gridTypeControl.selectedSegmentIndex) {
        case 1:
            gridType = PFNOTE_LINE_GRID_PAINTER;
            break;
        case 2:
            gridType = PFNOTE_BOX_GRID_PAINTER;
            break;
        case 3:
            gridType = PFNOTE_CROSS_GRID_PAINTER;
            break;
        default:
            break;
    }
    DECLARE_PFNOTE_MODEL
    [model.config setGridType:gridType];
    [self updateConfig:NO];
}

-(IBAction) onGridColorChanged:(id)sender {
    DECLARE_PFNOTE_MODEL
    UIButton *colorButton = (UIButton *)sender;
    NSInteger colorIndex = colorButton.tag - PFNOTE_SETUP_GRID_COLOR_TAG_START;
    [model.config setGridColorIndex:colorIndex];
    [model.inputPageConfig setGridColorIndex:colorIndex];
    [self updateGridColorSelectedIcon];
    [self updateConfig:NO];
}

#pragma mark -
#pragma mark Margin Sliders
-(void) onLeftRightChanged:(id)sender {
    DECLARE_PFNOTE_MODEL
    float margin = leftRightSlider.value;
    model.config.marginLeft = margin;
    model.config.marginRight = margin;
    [self updateConfig:YES];
}

-(void) onTopBottomChanged:(id)sender {
    DECLARE_PFNOTE_MODEL
    float margin = topBottomSlider.value;
    model.config.marginTop = margin;
    model.config.marginBottom = margin;
    [self updateConfig:YES];
}

-(void) onLineChanged:(id)sender {
    DECLARE_PFNOTE_MODEL
    float margin = lineSlider.value;
    model.config.marginLine = margin;
    [self updateConfig:YES];
}

-(void) onWordChanged:(id)sender {
    DECLARE_PFNOTE_MODEL
    float margin = wordSlider.value;
    model.config.marginWord = margin;
    [self updateConfig:YES];
}

-(void) onIndentChanged:(id)sender {
    DECLARE_PFNOTE_MODEL
    float margin = indentSlider.value;
    model.config.paragraphIndent = margin;
    [self updateConfig:YES];
}

-(void) onSpaceChanged:(id)sender {
    DECLARE_PFNOTE_MODEL
    float margin = spaceSlider.value;
    model.config.spaceWidth = margin;
    [self updateConfig:YES];
}

-(void) updateSliders {
    PFUTILS_delayWithInterval(0.0f, nil, _updateSliders:)
}

-(void) _updateSliders:(NSTimer *)timer {
    DECLARE_PFNOTE_MODEL
    [leftRightSlider setValue:model.config.marginLeft animated:YES];
    [topBottomSlider setValue:model.config.marginTop animated:YES];
    [lineSlider setValue:model.config.marginLine animated:YES];
    [wordSlider setValue:model.config.marginWord animated:YES];
    [indentSlider setValue:model.config.paragraphIndent animated:YES];
    [spaceSlider setValue:model.config.spaceWidth animated:YES];
}

-(void) resetSliders {
    [leftRightSlider setValue:leftRightSlider.minimumValue animated:NO];
    [topBottomSlider setValue:topBottomSlider.minimumValue animated:NO];
    [lineSlider setValue:lineSlider.minimumValue animated:NO];
    [wordSlider setValue:wordSlider.minimumValue animated:NO];
    [indentSlider setValue:indentSlider.minimumValue animated:NO];
    [spaceSlider setValue:spaceSlider.minimumValue animated:NO];
}

-(void) initSliders {
    DECLARE_PFNOTE_MODEL
    leftRightSlider.minimumValue = 0.0f;
    leftRightSlider.maximumValue = model.iPadMode ? 80.0f : 40.0f;
    topBottomSlider.minimumValue = 0.0f;
    topBottomSlider.maximumValue = model.iPadMode ? 80.0f : 40.0f;
    lineSlider.minimumValue = 0.0f;
    lineSlider.maximumValue = 1.0f;
    wordSlider.minimumValue = 0.0f;
    wordSlider.maximumValue = 1.0f;
    indentSlider.minimumValue = 0.0f;
    indentSlider.maximumValue = 2.0f;
    spaceSlider.minimumValue = 0.5f;
    spaceSlider.maximumValue = 2.0f;
    
    [leftRightSlider addTarget:self action:@selector(onLeftRightChanged:) forControlEvents:UIControlEventValueChanged];
    [topBottomSlider addTarget:self action:@selector(onTopBottomChanged:) forControlEvents:UIControlEventValueChanged];
    [lineSlider addTarget:self action:@selector(onLineChanged:) forControlEvents:UIControlEventValueChanged];
    [wordSlider addTarget:self action:@selector(onWordChanged:) forControlEvents:UIControlEventValueChanged];
    [indentSlider addTarget:self action:@selector(onIndentChanged:) forControlEvents:UIControlEventValueChanged];
    [spaceSlider addTarget:self action:@selector(onSpaceChanged:) forControlEvents:UIControlEventValueChanged];
}

-(void) updateConfig:(BOOL)needLayout {
    if (delegate) {
        [delegate onSetupDialogUpdate:needLayout];
    }    
}

-(IBAction) onCancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
