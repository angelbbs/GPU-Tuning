#include "Fivewin.ch"
#include "Report.ch"
#include "TcBrowse.ch"

#define K_BS  8

#define LINES_3D   3

#ifdef __XPP__
   #define Super ::TWBrowse
   #define New   _New
#endif

// #define USE_CONTEXT  // comment out if not using TWAContext() object
//введена переменная lNoTableHorScroll, не перемещать содержимое таблицы
//вправо-влево. скролбар при этом присутствует
// по умолчанию .t. - не перемещать

//----------------------------------------------------------------------------//

CLASS TCBrowse FROM TWBrowse

   CLASSDATA lRegistered AS LOGICAL

   CLASSDATA aProperties AS ARRAY ;
      INIT { "aColumns", "cVarName", "nTop", "nLeft", "nWidth", "nHeight" }

   DATA aColumns, aArray AS ARRAY
   DATA lNoHScroll, lNoTableHorScroll, lNoLiteBar, lNoGrayBar, lLogicDrop AS LOGICAL
   DATA nAdjColumn AS NUMERIC // column expands to flush table window right
   DATA lRePaint   AS LOGICAL   // bypass paint if false
   DATA nFreeze    AS NUMERIC // 0,1,2.. freezes left most columns
   DATA oDbf       AS OBJECT
   DATA oCtx       AS OBJECT
   DATA lColDrag, lLineDrag AS LOGICAL
   DATA nDragCol   AS NUMERIC
   DATA lAutoCtx   AS LOGICAL
   DATA hBmpCursor AS NUMERIC // bitmap cursor for first column
   DATA bSeekChange   AS CODEBLOCK      // added tws 5/15/95
   DATA cSeek         AS String  // added tws 5/15/95
   DATA nColOrder     AS NUMERIC    // added tws 5/15/95
   DATA nOClrForeHead AS NUMERIC    // added tws 5/15/95
   DATA nOClrBackHead AS NUMERIC    // added tws 5/15/95
   DATA cOrderType    AS String  // added hmvt
   DATA aImages                     // array with bitmaps names
   DATA aBitmaps                    // array with bitmaps handles

   METHOD New( nRow, nCol, nWidth, nHeigth, bLine, aHeaders, ;
                aColSizes, oWnd, cField, uVal1, uVal2, bChange,;
                bLDblClick, bRClick, oFont, oCursor, nClrFore,;
                nForeBack, cMsg, lUpdate, cAlias, lPixel, bWhen,;
                lDesign, bValid ) CONSTRUCTOR

   METHOD ReDefine( nId, bLine, oDlg, aHeaders, aColSizes, cField, uVal1,;
                      uVal2, bChange, bLDblClick, bRClick, oFont,;
                      oCursor, nClrFore, nClrBack, cMsg, lUpdate,;
                      cAlias, bWhen, bValid ) CONSTRUCTOR

   METHOD Destroy()    INLINE If( ::oCtx != Nil, ::oCtx:Destroy(), nil ), ;
                              Super:Destroy()      // destroy ClipMore filter

   METHOD GotFocus()   INLINE If( ::oCtx != nil, ::oCtx:Restore(), nil ), ;
                              Super:GotFocus()     // get context first

   METHOD Inspect( cData )

   METHOD LoadFields()

   METHOD LostFocus( hCtlFocus ) INLINE Super:LostFocus( hCtlFocus ), ; // save context last
                              If( ::oCtx != nil, ::oCtx:Save(), nil )

   METHOD BeginPaint() INLINE If(::lRepaint, Super:BeginPaint(), 0 )
   METHOD Paint()
   METHOD EndPaint()   INLINE If(::lRePaint, Super:EndPaint(), ;
                                     (::lRePaint := .t., 0) )

   METHOD Default()
   METHOD DrawLine( nRow )
   METHOD DrawSelect( )
   METHOD DrawHeaders( )
   METHOD ResetSeek()               // added tws 15/5/95
   METHOD SetOrder(nColumn)         // added tws 15/5/95
   METHOD GoDown()                  // added tws 15/5/95
   METHOD GoUp()                    // added tws 15/5/95
   METHOD Seek( nKey  )             // added tws 15/5/95
   METHOD PageUp(nLines)            // added tws 15/5/95
   METHOD PageDown(nLines)          // added tws 15/5/95
   METHOD KeyChar( nKey, nFlags )   // restored to support seek on pressing a key
   METHOD LButtonDown( nRowPix, nColPix, nKeyFlags )
   METHOD LButtonUp( nRowPix, nColPix, nKeyFlags )
   METHOD LDblClick( nRowPix, nColPix, nKeyFlags )
   METHOD lEditCol( nCol, uVar, cPicture, bValid, nClrFore, nClrBack, ;
                    cMsg, cError )
   METHOD nAtCol( nColPix, lActual )
   METHOD MouseMove( nRowPix, nColPix, nKeyFlags )
   METHOD Report( cTitle, lPreview )

   METHOD Reset() INLINE ::nRowPos := 1, ::nColPos := 1, ;
                  If(::oVScroll != nil, (;
                  ::oVScroll:SetRange( 1, ::nLen := Eval( ::bLogicLen, Self ) ), ;
                  ::oVScroll:SetPos( 1 ) ), nil), ::Refresh(.t.)

   METHOD ResetBarPos()
   METHOD SetArray( aArray )
   METHOD SetoDBF( oDbf )
   METHOD SetContext( oCtx )      INLINE If( oCtx == nil, ;
                                         ::lAutoCtx := .f., ::oCtx := oCtx )
   METHOD VertLineTc( nColPos, nColInit )

   METHOD AddColumn( oColumn )    INLINE AAdd( ::aColumns , oColumn ), ;
                                       AAdd( ::aColSizes, oColumn:nWidth ),;
                                       oColumn
   METHOD SwitchCols( nCol1, nCol2)
   METHOD Exchange( nCol1, nCol2) INLINE ::SwitchCols( nCol1, nCol2), ;
                                    ::Refresh(.f.),  ::SetFocus()

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nRow, nCol, nWidth, nHeigth, bLine, aHeaders, aColSizes, oWnd,;
            cField, uVal1, uVal2, bChange, bLDblClick, bRClick,;
            oFont, oCursor, nClrFore, nClrBack, cMsg, lUpdate, cAlias,;
            lPixel, bWhen, lDesign, bValid ) CLASS TCBrowse

            DEFAULT lDesign := .f., aColSizes := {}

        // I asked AL to Chg TWBrowse:New() change ::sStyle  = nOr(... to
        // DEFAULT ::nStyle := nOr(... so we can modify the style
        // NS HMVT you gotta take WS_HSCROLL out otherwise you always get it
        ::nStyle := nOr( WS_CHILD, WS_VSCROLL, ; // WS_HSCROLL,;
                       WS_BORDER, WS_VISIBLE, WS_TABSTOP,;
                       If( lDesign, WS_THICKFRAME, 0 ) )

      ::lAutoCtx   := .t.
      ::lRePaint   := .f.
      ::lNoHScroll := .f.
      ::lNoTableHorScroll := .t.
      ::lNoLiteBar := .f.
      ::lNoGrayBar := .f.
      ::lLogicDrop := .f.
      ::lColDrag   := .f.
      ::lLineDrag  := .f.
      ::nFreeze    := 0
      ::aColumns   := {}
      ::nColOrder  := 0
      ::cOrderType := ""
      ::aImages    := {}
      ::aBitmaps   := {}

      DEFAULT ::lRegistered := .f.

        Super:New( nRow, nCol, nWidth, nHeigth, bLine, aHeaders, aColSizes, oWnd, ;
                  cField, uVal1, uVal2, bChange, bLDblClick, bRClick, ;
                  oFont, oCursor, nClrFore, nClrBack, cMsg, lUpdate, cAlias, ;
                  lPixel, bWhen, lDesign, bValid )

#ifdef __XPP__
   #undef New
#endif

Return self

//----------------------------------------------------------------------------//

METHOD ReDefine( nId, bLine, oDlg, aHeaders, aColSizes, cField, uVal1, uVal2,;
                 bChange, bLDblClick, bRClick, oFont, oCursor,;
                 nClrFore, nClrBack, cMsg, lUpdate, cAlias,;
                 bWhen, bValid ) CLASS TCBrowse

      DEFAULT aColSizes := {}

      ::lAutoCtx   := .t.
      ::lRePaint   := .f.
      ::lNoHScroll := .f.
      ::lNoTableHorScroll := .t.
      ::lNoLiteBar := .f.
      ::lNoGrayBar := .f.
      ::lLogicDrop := .f.
      ::lColDrag   := .f.
      ::lLineDrag  := .f.
      ::nFreeze    := 0
      ::aColumns   := {}
      ::nColOrder  := 0
      ::cOrderType := ""
      ::aImages    := {}
      ::aBitmaps   := {}

      Super:Redefine( nId, bLine, oDlg, aHeaders, aColSizes, cField, uVal1, uVal2, ;
                      bChange, bLDblClick, bRClick, oFont, oCursor, ;
                      nClrFore, nClrBack, cMsg, lUpdate, cAlias,;
                      bWhen, bValid )

Return self

//----------------------------------------------------------------------------//

METHOD LoadFields() CLASS TcBrowse

   local n, oCol

   for n = 1 to ( ::cAlias )->( FCount() )
      ::AddColumn( oCol := TcColumn():New( ( ::cAlias )->( FieldName( n ) ),;
                   FieldSetGetBlock( ::cAlias, n ) ) )
      oCol:lEdit = .t.
      oCol:cData = ::cAlias + "->" + FieldName( n )
      if ( ::cAlias )->( ValType( FieldGet( n ) ) ) == "N"
         oCol:nAlign = 2 // RIGHT
      endif
   next

return nil

//----------------------------------------------------------------------------//

static function FieldSetGetBlock( cAlias, n )

return { | u | If( PCount() == 0,;
                 ( cAlias )->( FieldGet( n ) ),;
                 ( cAlias )->( FieldPut( n, u ) ) ) }

//----------------------------------------------------------------------------//

METHOD nAtCol( nColPixel, lActual ) CLASS TCBrowse

   local nColumn := ::nColPos - 1
   local aSizes  := ::GetColSizes()
   local nI, nPos := 0

   DEFAULT lActual := .f.

   if ::nFreeze > 0
     if lActual
       nColumn := 0
     else
       for nI := 1 to ::nFreeze
         nPos += ::GetColSizes()[ nI ]
       next
     endif
   endif

   while nPos < nColPixel .and. nColumn < Len( aSizes )
      nPos += aSizes[ nColumn + 1 ]
      nColumn++
   end

return nColumn

//----------------------------------------------------------------------------//

METHOD Paint() CLASS TCBrowse

   local nI       := 1
   local nLines   := ::nRowCount() + If( ::lNoHScroll, 1, 0 )
   local nSkipped := 1
   local nRecs
   local aInfo := ::DispBegin()

   FillRect( ::hDC, GetClientRect( ::hWnd ), ::oBrush:hBrush )
   // check to bypass area paint routines
   if ! ::lRePaint
      ::DispEnd( aInfo )
      return 0
   endif

   if ::lIconView
      ::DispEnd( aInfo )
      ::DrawIcons()
      return 0
   endif

   if ::nRowPos == 1 .and. ( ! Empty( ::cAlias ) ) .and. ;
      ::cAlias != "ARRAY"
      ( ::cAlias )->( DbSkip( -1 ) )
      if ! ( ::cAlias )->( BoF() )
         ( ::cAlias )->( DbSkip() )
      endif
   endif

   ::DrawHeaders()

   if ! ::lFocused .and. ::oCtx != nil
      ::oCtx:Restore()  // window not in focus but needs repainting
   endif

   if Eval( ::bLogicLen, Self ) == 0
      ::DispEnd( aInfo )
      return 0
   endif

   ::Skip( -::nRowPos + 1) // If(::lNoHScroll, 0, 1 ) )
   while nI <= nLines .and. nSkipped == 1
      ::DrawLine( nI )
      nSkipped = ::Skip( 1 )
      if nSkipped == 1

         nI++
      endif
   end
//?nI
   ::Skip( ::nRowPos - nI )
   if ( nRecs := Eval( ::bLogicLen, Self ) ) < ::nRowPos
      ::nRowPos = nRecs
   endif
   ::DrawSelect()

   if ! ::lFocused .and. ::oCtx != nil
      ::oCtx:Save()
   endif

   ::DispEnd( aInfo )

return 0

//----------------------------------------------------------------------------//

METHOD DrawHeaders( ) CLASS TCBrowse

    Local nI, nJ, nBegin, nStartCol, oColumn, nLastCol
    Local nMaxWidth := ::nWidth()
    Local aColSizes := ::aColSizes   // use local copies for speed
    Local aColumns  := ::aColumns
    Local hFont := If( ::oFont != nil, ::oFont:hFont, 0 )
    Local hWnd := ::hWnd, hDC := ::hDC
    Local nClrForeHead  := ::nClrForeHead
    Local nClrBackHead  := ::nClrBackHead
    Local nOClrForeHead := if(::nOClrForeHead = Nil, ;
                                   nClrForeHead,::nOClrForeHead)
          Local nOClrBackHead := if(::nOClrBackHead = Nil, ;
                                   nClrBackHead,::nOClrBackHead)

    if ::aColSizes == nil .or. Len( ::aColSizes ) < Len( ::aColumns )
       ::aColSizes = {}
       for nI = 1 to Len( ::aColumns )
          AAdd( ::aColSizes, ::aColumns[ nI ]:nWidth )
       next
       aColSizes = ::aColSizes
    endif

    nJ := nStartCol := 0
    nLastCol := Len(aColumns)  // last col width -1 is flag for TCDrawCell
    nBegin := Min(If( (::nColPos <= ::nFreeze .or. ::lNoTableHorScroll=.t.), (::nColPos := ::nFreeze+1, ::nColPos-::nFreeze),::nColPos-::nFreeze), nLastCol )

    if Empty( aColumns )
       return Self
    endif

    for nI := nBegin to nLastCol

      if ( nStartCol > nMaxWidth )
        Exit
      endif

      nJ := If( nI < ::nColPos, nJ+1, nI)

      oColumn := aColumns[ nJ ]

      TCDrawCell( hWnd, hDC, ;
                0, nStartCol, If( nJ < nLastCol, aColSizes[ nJ ], -1), ;
                oColumn:cHeading, oColumn:nAlign, ;
                if(!Empty(oColumn:cOrder),nOClrForeHead,nClrForeHead), ;
                if(nJ = ::nColOrder,nOClrBackHead,nClrBackHead), ;
                  hFont,,, LINES_3D )

//                if(nJ = ::nColOrder,nOClrForeHead,nClrForeHead), ;

      nStartCol += aColSizes[ nJ ]

    next

Return( Self )

//----------------------------------------------------------------------------//

METHOD DrawLine( xRow ) CLASS TCBrowse

    Local nI, nJ, nBegin, nStartCol, oColumn, lBitMap, cPicture
    Local nClrFore, bClrFore, nClrBack, bClrBack
    Local nMaxWidth := ::nWidth()
    Local nRowPos   := ::nRowPos     // use local copies for speed
    Local aColSizes := ::aColSizes, nLastCol
    Local aColumns  := ::aColumns
    Local hFont := If( ::oFont != nil, ::oFont:hFont, 0 )
    Local hWnd := ::hWnd, hDC := ::hDc

    if Eval( ::bLogicLen, Self ) > 0

      nJ := nStartCol := 0
      nLastCol := Len(aColumns) // last col width -1 is flag for TCDrawCell
//      nBegin := Min(If(::nColPos <= ::nFreeze, (::nColPos := ::nFreeze+1, ::nColPos-::nFreeze),::nColPos-::nFreeze), nLastCol )
      nBegin := Min(If( (::nColPos <= ::nFreeze .or. ::lNoTableHorScroll=.t.), (::nColPos := ::nFreeze+1, ::nColPos-::nFreeze),::nColPos-::nFreeze), nLastCol )

      for nI := nBegin to nLastCol

        if ( nStartCol > nMaxWidth )
          Exit
        endif

        nJ := If( nI < ::nColPos, nJ+1, nI)

        oColumn  := aColumns[ nJ ]
        cPicture := oColumn:cPicture
        lBitMap  := oColumn:lBitMap

        if (bClrFore := oColumn:bClrFore) == nil
          nClrFore := ::nClrText
        else
          nClrFore := bClrFore
        endif

        if ValType( nClrFore ) == "B"
          nClrFore := Eval( nClrFore, If( xRow == nil, nRowPos, xRow ), nJ )
        endif

        if (bClrBack := oColumn:bClrBack) == nil
          nClrBack := ::nClrPane
        else
          nClrBack := bClrBack
        endif

        if ValType( nClrBack ) == "B"
          nClrBack := Eval( nClrBack, If( xRow == nil, nRowPos, xRow ), nJ )
        endif

        TCDrawCell( hWnd, hDC , ;
              If( xRow == nil, nRowPos, xRow ) , nStartCol ,;
              If( nJ < nLastCol, aColSizes[ nJ ], -1) , ;
              if( cPicture == nil, ;
                  If( lBitMap, If( ! Empty( ::aBitmaps ),;
                  ::aBitmaps[ Eval( oColumn:bData ) ], Eval( oColumn:bData ) ), ;
                    cValToChar( Eval( oColumn:bData )) ), ;
                  Transform( Eval( oColumn:bData ), cPicture ) ),  ;
              oColumn:nAlign , ;
              nClrFore, nClrBack, ;
              hFont,;
              If(lBitMap, 1, 0),, ::nLineStyle )

        nStartCol += aColSizes[ nJ ]
      next
    endif

Return( Self )

//----------------------------------------------------------------------------//

METHOD DrawSelect() CLASS TCBrowse

   local nI, nJ, nBegin, nStartCol, oColumn, nLastCol, lBitMap, cPicture
   local bClrFore, bClrBack, nClrFore, nClrBack, lNoLite, uData
   local nMaxWidth := ::nWidth()
   local nRowPos   := ::nRowPos   // use local copies for speed
   local aColSizes := ::aColSizes
   local aColumns  := ::aColumns
   local hFont := If( ::oFont != nil, ::oFont:hFont, 0 )
   local hWnd := ::hWnd, hDC := ::hDc, lFocused := ::lFocused
   local nClrForeFocus := ::nClrForeFocus
   local nClrBackFocus := ::nClrBackFocus

   if ( ::lNoLiteBar .or. (::lNoGrayBar .and. !::LFocused) )

      ::DrawLine()   // don't want no hilited cursor bar of any color

   elseif Eval( ::bLogicLen, Self ) > 0

      nJ := nStartCol := 0
      nLastCol := Len(aColumns) // last col width -1 is flag for TCDrawCell
//      nBegin := Min(If(::nColPos <= ::nFreeze, (::nColPos := ::nFreeze+1,;
//                  ::nColPos-::nFreeze),::nColPos-::nFreeze), nLastCol )
    nBegin := Min(If( (::nColPos <= ::nFreeze .or. ::lNoTableHorScroll=.t.), (::nColPos := ::nFreeze+1, ::nColPos-::nFreeze),::nColPos-::nFreeze), nLastCol )


      for nI := nBegin to nLastCol

        if ( nStartCol > nMaxWidth )
          Exit
        endif

        nJ := If( nI < ::nColPos, nJ+1, nI)

        oColumn  := aColumns[ nJ ]

        if nJ == 1 .and. ! Empty( ::hBmpCursor )
          uData    := ::hBmpCursor
          lBitMap  := .t.
          lNoLite  := .t.
        else
          uData    := Eval( oColumn:bData )
          cPicture := oColumn:cPicture
          lBitMap  := oColumn:lBitMap
          lNoLite  := oColumn:lNoLite
        endif

        if lNoLite
          if (bClrFore := oColumn:bClrFore) == nil // text
            nClrFore := ::nClrText
          else
            nClrFore := bClrFore
          endif

          if ValType( nClrFore ) == "B"
             nClrFore = Eval( nClrFore, nRowPos, nJ )
          endif

          if (bClrBack := oColumn:bClrBack) == nil // backgnd nClrBackFocus
            nClrBack := ::nClrPane
          else
            nClrBack := bClrBack
          endif

          if ValType( nClrBack ) == "B"
             nClrBack = Eval( nClrBack, nRowPos, nJ )
          endif
        else
          if ! ::lCellStyle .or. ::nColAct == nJ
             nClrFore := nClrForeFocus
          else
             if (bClrFore := oColumn:bClrFore) == nil // backgnd nClrBackFocus
                nClrFore = ::nClrText
             else
                nClrFore = Eval( bClrFore )
             endif
             if ValType( nClrFore ) == "B"
                nClrFore = Eval( nClrFore, nRowPos, nJ )
             endif
          endif

          if ! ::lCellStyle .or. ::nColAct == nJ
             nClrBack := nClrBackFocus
          else
             if (bClrBack := oColumn:bClrBack) == nil // backgnd nClrBackFocus
                nClrBack = ::nClrPane
             else
                nClrBack = Eval( bClrBack )
             endif
             if ValType( nClrBack ) == "B"
                nClrBack = Eval( nClrBack, nRowPos, nJ )
             endif
          endif
        endif

        TCDrawCell( hWnd, hDC, ;
              nRowPos, nStartCol, If( nJ < nLastCol, aColSizes[ nJ ], -1), ;
              if( cPicture == nil, ;
                  If( lBitMap, If( ! Empty( ::aBitmaps ),;
                    ::aBitmaps[ uData ], uData ), ;
                    cValToChar( Eval( oColumn:bData ) ) ), ;
                      Transform( uData, cPicture ) ), ;
              oColumn:nAlign, ;
              nClrFore, ;
              If( lFocused .or. lNoLite,;
                  nClrBack,;
                  If( ::lCellStyle, If( nJ == ::nColAct, CLR_GRAY, nClrBack ), CLR_GRAY ) ),;
              hFont, ;
              If(lBitMap, If(lNoLite, 1, 2), 0),, ::nLineStyle )

        nStartCol += aColSizes[ nJ ]
      next
    endif

Return( Self )

//----------------------------------------------------------------------------//

METHOD SetoDbf( oDbf ) CLASS TCBrowse

   ::oDbf  = oDbf

   if ( Upper( oDbf:ClassName() ) == "TMULTIDBF")
     // setup for the parent as the controlling oDbf
     ::oCtx := oDbf:oCtx
     ::oDbf:oParent:bBof = nil
     ::oDbf:oParent:bEof = nil
   else
     ::oDbf:bBof = nil  // get rid of those pesky
     ::oDbf:bEof = nil  // dialog boxes
   endif

   ::nRowPos := 1  // reinitialize for multiple calls to this method
   ::nColPos := 1

   ::cAlias    = "DBFOBJECT"  // don't change name, used in method Default()

   ::bLogicLen = { || ::oDbf:RecCount() }
   ::bGoTop    = { || ::oDbf:GoTop() }
   ::bGoBottom = { || ::oDbf:GoBottom() }
   ::bSkip     = { | nSkip | ::oDbf:Skipper( nSkip ) }

return nil

//----------------------------------------------------------------------------//

METHOD SetArray( aArray ) CLASS TCBrowse

   DEFAULT aArray := {}

   ::aArray    = aArray   // NS HMVT added this, it's NICE to have

   ::nAt       = 1
   ::cAlias    = "ARRAY"  // don't change name, used in method Default()
   ::bLogicLen = { || Len( ::aArray ) }
   ::bGoTop    = { || ::nAt := 1 }
   ::bGoBottom = { || ::nAt := Eval( ::bLogicLen ) }
   ::bSkip     = { | nSkip, nOld | nOld := ::nAt, ::nAt += nSkip,;
                  ::nAt := Min( Max( ::nAt, 1 ), Eval( ::bLogicLen, Self ) ),;
                  ::nAt - nOld }

   ::nRowPos := 1  // reinitialize for multiple calls to this method
   ::nColPos := 1

   if ::oVScroll != nil
     ::oVScroll:SetRange( 1, ::nLen := Eval( ::bLogicLen, Self ) )
     ::oVScroll:SetPos( 1 )
   endif
   if ::oHScroll != nil
     ::oHScroll:SetPos( 1 )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD Default() CLASS TCBrowse

    local nI, nTemp, nWidth := 0
    local nMaxWidth := ::nWidth() - 16

    ASize( ::aColSizes, Len( ::aColumns ) ) // make sure they match sizes

    If( Empty(::nOClrForeHead), ::nOClrForeHead := CLR_HRED, )
    If( Empty(::nOClrBackHead), ::nOClrBackHead := CLR_HBLUE, )

    // rebuild build the aColSize, it's needed to Horiz Scroll etc
    // and expand selected column to flush table window right
    for nI := 1 to Len( ::aColumns )
      nTemp := ::aColSizes[nI] := ::aColumns[nI]:nWidth
      if !Empty(::nAdjColumn).and.(nWidth + nTemp > nMaxWidth)
        if ::nAdjColumn < nI
          ::aColumns[::nAdjColumn]:nWidth := ;
          ::aColSizes[::nAdjColumn] += (nMaxWidth - nWidth)
        endif
        ::nAdjColumn := 0
      endif
      nWidth += nTemp

      if (::nColOrder == 0) .and. (::cAlias != "ARRAY") .and. ;
              ( !Empty(::aColumns[nI]:cOrder) )
        ::SetOrder( nI )  // establish a default if one exists
      endif

    next

    // now catch the odd-ball where last column doesn't fill box
    if !Empty(::nAdjColumn).and.(nWidth < nMaxWidth).and.(::nAdjColumn < nI)
      ::aColumns[::nAdjColumn]:nWidth := ;
      ::aColSizes[::nAdjColumn] += (nMaxWidth - nWidth)
      ::nAdjColumn := 0
    endif

    ::nLen = Eval( ::bLogicLen, Self )
    IF ::nLen == nil
       ::nLen = 0
    ENDIF

    DEFINE SCROLLBAR ::oVScroll VERTICAL OF Self ;
        RANGE Min( 1, ::nLen ), ::nLen

#ifdef USE_CONTEXT
    if ::oCtx == nil .and. ( !Empty(::cAlias) .and. ::cAlias != "ARRAY" ) ;
       .and. ::lAutoCtx
      // a context hasn't been established, and not browsing arrays
      if ::cAlias == "DBFOBJECT"
        ::oCtx := TWAContext():New( ::oDbf:cAlias )
      else
        ::oCtx := TWAContext():New( ::cAlias )
      endif
    endif
#endif

    // if ::oCtx != nil .and. !Empty(::oCtx:uRecNo)
    //   ::oVScroll:SetPos( ::oCtx:uRecNo )
    // endif

    ::ResetBarPos()

   if !::lNoHScroll
    DEFINE SCROLLBAR ::oHScroll HORIZONTAL OF Self ;
        RANGE Min( 1, Len( ::GetColSizes() ) ), Len( ::GetColSizes() )
   endif

   if ::oFont == nil
      ::oFont = ::oWnd:oFont
   endif

return self

//----------------------------------------------------------------------------//

METHOD MouseMove( nRowPix, nColPix, nKeyFlags ) CLASS TCBrowse

  local nI, nColPixPos := 0, lHeader, lMChange, lFrozen := .f., nIcon

   DEFAULT ::lMouseDown := .f.

   if ::lIconView
      if ( nIcon := ::nAtIcon( nRowPix, nColPix ) ) != 0
         if ::nIconPos != 0 .and. ::nIconPos != nIcon
            ::DrawIcon( ::nIconPos )
         endif
         ::nIconPos = nIcon
         ::DrawIcon( nIcon, .t. )
         CursorHand()
         return 0
      endif
   endif


   lHeader :=  nTCWRow( ::hWnd, ::hDC, nRowPix,;
                 If( ::oFont != nil, ::oFont:hFont, 0 ) ) == 0

   if ::lDrag
      return Super:MouseMove( nRowPix, nColPix, nKeyFlags )
   endif

   if ::nFreeze > 0
     for nI := 1 to ::nFreeze
       nColPixPos += ::GetColSizes()[ nI ]
     next
     if (nColPix < nColPixPos)
       lFrozen := .t.
     endif
   endif

   if lFrozen .or. !lHeader .or. !::lMChange

       // don't allow MouseMove to drag/resize columns
       // unless in header row and not in frozen zone
       CursorArrow()
       if ::lCaptured
         if ::lLineDrag
           ::VertLineTc()
           ::lLineDrag := .f.
         endif
         ReleaseCapture()
         ::lColDrag := ::lCaptured := ::lMouseDown := .f.
       endif
       lMChange := ::lMChange  // save it for restore
       ::lMChange := .f.
       Super:MouseMove( nRowPix, nColPix, nKeyFlags )
       ::lMChange := lMChange
       return 0
   endif

   if ::lDrag
      return Super:MouseMove( nRowPix, nColPix, nKeyFlags )
   else
      if ::lMChange
         if lHeader
            if ::lColDrag
               CursorCatch()
            else
               if ::lLineDrag
                  ::VertLineTc( nColPix )
                  CursorWE()
               else
                  if AScan( ::GetColSizes(),;
                       { | nColumn | nColPixPos += nColumn,;
                       nColPix >= nColPixPos - 2 .and. ;
                       nColPix <= nColPixPos + 2 }, ::nColPos ) != 0
                     CursorWE()
                  else
                     CursorHand()
                  endif
               endif
            endif
         else
            CursorArrow()
         endif
      else
         CursorArrow()
      endif
   endif

return 0

//----------------------------------------------------------------------------//

METHOD VertLineTc( nColPixPos, nColInit ) CLASS TCBrowse

   local oRect

   static nCol, nWidth, nOldPixPos := 0

   if nColInit != nil
      nCol    = nColInit
      nWidth  = nColPixPos
      nOldPixPos = 0
   endif
   if nColPixPos == nil .and. nColInit == nil   // We have finish draging
      ::aColSizes[ nCol ] -= ( nWidth - nOldPixPos )
      ::aColumns[ nCol ]:nWidth -= ( nWidth - nOldPixPos )  // HMVT added
      ::Refresh()
   endif

   oRect = ::GetRect()
   ::GetDC()
   if nOldPixPos != 0
      InvertRect( ::hDC, { 0, nOldPixPos - 1, oRect:nBottom, nOldPixPos + 1 } )
      nOldPixPos = 0
   endif
   if nColPixPos != nil .and. ( nColPixPos - 1 ) > 0
      InvertRect( ::hDC, { 0, nColPixPos - 1, oRect:nBottom, nColPixPos + 1 } )
      nOldPixPos = nColPixPos
   endif
   ::ReleaseDC()

return nil

//----------------------------------------------------------------------------//

METHOD lEditCol( nCol, uVar, cPicture, bValid, nClrFore, nClrBack, ;
                 cMsg, cError ) CLASS TCBrowse

   local oDlg, oGet, oFont, oBtn
   local nWidth := ::aColSizes[ nCol ]
   local uTemp  := uVar, aDim, lOk := .f.
   local lDropBox := ( ValType( uVar )== "L" .and. ::lLogicDrop )
   local nI, nStartCol := 0, lLogicDrop := ::lLogicDrop

   if ::nFreeze > 0
     for nI := 1 to Min(::nFreeze , nCol - 1 )
       nStartCol += ::GetColSizes()[ nI ]
     next
   endif

   for nI := ::nColPos to nCol - 1
     nStartCol += ::aColSizes[ nI ]
   next

   DEFAULT nClrFore := ::nClrText, nClrBack := ::nClrPane

   if ValType( Eval( ::aColumns[ nCol ]:bData ) ) == "M"
      if MemoEdit( @uTemp, "Editing: " + ::aColumns[ nCol ]:cHeading )
         uVar = uTemp
         return .t.
      else
         return .f.
      endif
   endif

   if ::oFont != nil .and. ! Empty( ::oFont:nHeight )
     // added default font of system 14 500 weight
     oFont = TFont():New( ::oFont:cFaceName, ::oFont:nInpWidth,;
              If( Abs( ::oFont:nInpHeight ) < 14, 14, ::oFont:nInpHeight ), .f., ;
                ::oFont:lBold, nil, nil, If(::oFont:lBold, nil, 500) )
   endif

   aDim := aTCBrWPosRect( ::hWnd, ::nRowPos, nStartCol, nWidth, ;
                          If( ::oFont != nil, ::oFont:hFont, 0 ) )

   DEFINE DIALOG oDlg OF ::oWnd  FROM aDim[ 1 ], aDim[ 2 ] TO aDim[ 3 ], aDim[ 4 ] ;
      STYLE nOR( WS_VISIBLE, WS_POPUP ) PIXEL

   if ( lDropBox )
      uTemp = If( uVar, "Yes", "No" )
      oGet := TComboBox():New( 0, 0, bSETGET(uTemp), { "Yes", "No" }, ;
              aDim[ 4 ] - aDim[ 2 ], 32, oDlg, , , bValid, nClrFore, ;
              nClrBack, .t., oFont, cMsg )  // 32 was 100
      oGet:oGet := oGet
      oGet:cError := cError
   else
      oGet := TGet():New( 0, 0, bSETGET( uTemp ), oDlg, ;
               aDim[ 4 ] - aDim[ 2 ], aDim[ 3 ] - aDim[ 1 ], ;
               cPicture, bValid, nClrFore, nClrBack, oFont )
      oGet:cMsg   := cMsg
      oGet:cError := cError
   endif

   @ 10, 0 BUTTON oBtn PROMPT "" ACTION ( oBtn:SetFocus(), oDlg:End(), lOk := .t. ) OF oDlg

   oBtn:nStyle = nOr( WS_CHILD, WS_VISIBLE, BS_DEFPUSHBUTTON )

   ACTIVATE DIALOG oDlg ;
      ON INIT ( oDlg:Move( aDim[ 1 ] + 1, aDim[ 2 ] + 1,;
                           aDim[ 4 ] - aDim[ 2 ], aDim[ 3 ] - aDim[ 1 ] ),;
                If( lDropBox,;
                oGet:Move( -5, -2, aDim[ 4 ] - aDim[ 2 ] + 3, 22 ), ;// 22 was 80
                oGet:Move( -2, -1, aDim[ 4 ] - aDim[ 2 ] + 3, ;
                           aDim[ 3 ] - aDim[ 1 ] + 6 ) ) )

   if lOk
     if ( lDropBox )
        uVar = ( uTemp == "Yes" )
     else
        uVar = uTemp
     endif
   endif

return lOk

//----------------------------------------------------------------------------//

METHOD LDblClick( nRowPix, nColPix, nKeyFlags ) CLASS TCBrowse

   local nClickRow := nTCWRow( ::hWnd, ::hDC, nRowPix,;
                             If( ::oFont != nil, ::oFont:hFont, 0 ) )
   local nCol
   local uTemp

   if nClickRow == ::nRowPos
     if ::aColumns[ nCol := ::nAtCol( nColPix ) ]:lEdit .and. ::lAutoEdit
        uTemp = Eval( ::aColumns[ nCol ]:bData )
        if ::lEditCol( nCol, @uTemp )
           if ! Empty( ::cAlias ) .and. ::cAlias != "ARRAY"
              if ( ::cAlias )->( RLock() )
                 Eval( ::aColumns[ nCol ]:bData, uTemp )
                 ( ::cAlias )->( DbUnLock() )
              else
                 MsgStop( "Record in use", "Please, try again" )
              endif
           else
              Eval( ::aColumns[ nCol ]:bData, uTemp )
           endif
           ::DrawSelect()
        endif
     endif
     if ::bLDblClick != nil
        Eval( ::bLDblClick, nRowPix, nColPix, nKeyFlags )
     endif
   elseif nClickRow == 0
     ::SetOrder( ::nAtCol( nColPix ) )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD LButtonDown( nRowPix, nColPix, nKeyFlags ) CLASS TCBrowse

   local nClickRow, nSkipped, nI
   local nColPixPos := 0, nColInit := ::nColPos - 1
   local oRect, nIcon

   if ::nFreeze > 0
     for nI := 1 to ::nFreeze
       nColPixPos += ::GetColSizes()[ nI ]
     next
   endif

   if ::lDrag
      return Super:LButtonDown( nRowPix, nColPix, nKeyFlags )
   endif

   nClickRow = nTCWRow( ::hWnd, ::hDC, nRowPix,;
                      If( ::oFont != nil, ::oFont:hFont, 0 ) )

   ::SetFocus()

   if ::lIconView
      if ( nIcon := ::nAtIcon( nRowPix, nColPix ) ) != 0
         ::DrawIcon( nIcon )
      endif
      return nil
   endif

   if ::lMChange
      if nClickRow == 0
         if AScan( ::GetColSizes(),;
                   { | nColumn | nColPixPos += nColumn,;
                     nColInit++,;
                     nColPix >= nColPixPos - 2 .and. ;
                     nColPix <= nColPixPos + 2 }, ::nColPos ) != 0
            ::lLineDrag = .t.
            ::VertLineTc( nColPixPos, nColInit )
         else
            ::lColDrag = .t.
            ::nDragCol = ::nAtCol( nColPix )
         endif
         if ! ::lCaptured
            ::lCaptured = .t.
            ::Capture()
         endif
         return nil
      endif
   endif

   if ::nLen < 1
      return nil
   endif

   if nClickRow > 0 .and. nClickRow < ::nRowCount() + 1  //EMG
      ::DrawLine()
      nSkipped  = ::Skip( nClickRow - ::nRowPos )
      ::nRowPos += nSkipped
      ::oVScroll:SetPos( ::oVScroll:GetPos() + nSkipped )
      if ::lCellStyle
           ::nColAct := ::nAtCol( nColPix )
           if ::oHScroll != nil
              ::oHScroll:SetPos(::nColAct)
           endif
      endif
      ::DrawSelect()
      ::lHitTop = .f.
      ::lHitBottom = .f.
      if ::bChange != nil
         Eval( ::bChange )
      endif
   else
      return nil
   endif
   if nClickRow == ::nRowPos
      if ::lCellStyle
           ::nColAct := ::nAtCol( nColPix )
           if ::oHScroll != nil
              ::oHScroll:SetPos(::nColAct)
           endif
           ::DrawSelect()
      endif
   endif

   Super:LButtonDown( nRowPix, nColPix, nKeyFlags )

return 0

//----------------------------------------------------------------------------//

METHOD LButtonUp( nRowPix, nColPix, nFlags ) CLASS TCBrowse

   local nClickRow, nDestCol, nAtCol

   if ::lDrag
     if ::lColDrag
        ::lDrag := .f.
     else
        return Super:LButtonUp( nRowPix, nColPix, nFlags )
     endif
   endif

   nClickRow = nTCWRow( ::hWnd, ::hDC, nRowPix,;
                        If( ::oFont != nil, ::oFont:hFont, 0 ) )

   if ::lCaptured
      ::lCaptured = .f.
      ReleaseCapture()
      if ::lLineDrag
        ::lLineDrag := .f.
        ::VertLineTc()
      else
        ::lColDrag := .f.
        nDestCol := ::nAtCol( nColPix )
        // we gotta be on header row within listbox and not same colm
        #ifdef __XPP__
           DEFAULT ::nRight := ::nWidth()
        #endif
        if nClickRow == 0 .and. nColPix > ::nLeft .and. ;
           nColPix < ::nRight - 16 .and. ::nDragCol != nDestCol
             ::Exchange( ::nDragCol, nDestCol)
        endif
      endif
   endif

   if nClickRow == 0 .and. ::aActions != nil .and. ;
      ( nAtCol := ::nAtCol( nColPix ) ) <= Len( ::aActions )
      if ::aActions[ nAtCol ] != nil
         Eval( ::aActions[ nAtCol ], Self, nRowPix, nColPix )
         return nil
      endif
   endif

   Super:LButtonUp( nRowPix, nColPix, nFlags )

return nil

//----------------------------------------------------------------------------//

METHOD GoDown() CLASS TCBrowse

   local nSkipped
   local nLines := ::nRowCount()

   if ::nLen < 1
      return nil
   endif

   ::ResetSeek()
        if ::bSeekChange != Nil
                eval(::bSeekChange)
        endif

   if ! ::lHitBottom
      ::DrawLine()
      if ::Skip( 1 ) == 1
         ::lHitTop = .f.
         if ::nRowPos < nLines
            ::nRowPos++
         else
            ::lRePaint := .f.
            TCBrwScroll( ::hWnd, 1, If( ::oFont != nil, ::oFont:hFont, 0 ) )
            ::nRowPos := nLines
         endif
      else
         ::lHitBottom = .t.
      endif
      ::DrawSelect()
      if ::oVScroll != nil
         ::oVScroll:GoDown()
      endif
      if ::bChange != nil
         Eval( ::bChange )
      endif
   endif


return nil

//---------------------------------------------------------------------------//

METHOD GoUp() CLASS TCBrowse

   local nSkipped
   local nLines := ::nRowCount()

   if ::nLen < 1
      return nil
   endif

   ::ResetSeek()
        if ::bSeekChange != Nil
                eval(::bSeekChange)
        endif

   if ! ::lHitTop
      ::DrawLine()
      if ::Skip( -1 ) == -1
         ::lHitBottom = .f.
         if ::nRowPos > 1
            ::nRowPos--
         else
            ::lRePaint := .f.
            TCBrwScroll( ::hWnd, -1, If( ::oFont != nil, ::oFont:hFont, 0 ) )
            ::DrawLine()
         endif
      else
         ::lHitTop = .t.
      endif
      ::DrawSelect()
      if ::oVScroll != nil
         ::oVScroll:GoUp()
      endif
      if ::bChange != nil
         Eval( ::bChange )
      endif
   endif

return nil

//---------------------------------------------------------------------------//

// The following method is dedicated to John Stolte by the 'arry

METHOD SwitchCols( nCol1, nCol2 ) CLASS TcBrowse

  local oHolder, nHolder, nMaxCol := Len(::aColumns)

  if nCol1 > ::nFreeze .and. nCol2 > ::nFreeze .and. ;
     nCol1 <= nMaxCol .and. nCol2 <= nMaxCol

    oHolder := ::aColumns[ nCol1 ]
    nHolder := ::aColSizes[ nCol1 ]

    ::aColumns[ nCol1 ]  := ::aColumns[ nCol2 ]
    ::aColSizes[ nCol1 ] := ::aColSizes[ nCol2 ]

    ::aColumns[ nCol2 ]  := oHolder
    ::aColSizes[ nCol2 ] := nHolder

    if ::nColOrder == nCol1
      ::nColOrder := nCol2
    endif

  endif

return self
//----------------------------------------------------------------------------//

static function GenHead( aArray, nPos ) ; return {|| aArray[nPos]:cHeading }

static function GenData( aArray, nPos ) ; return {|| ;
                     If( aArray[nPos]:cPicture!=nil, ;
                   Transform( Eval(aArray[nPos]:bData), aArray[nPos]:cPicture), ;
                                      cValToChar(Eval(aArray[nPos]:bData))) }

//----------------------------------------------------------------------------//

METHOD Report( cTitle, lPreview ) CLASS TCBrowse

   local oRpt, oColumn, cPicture
   local nRecNo, nI

   DEFAULT cTitle := ::oWnd:GetText(), lPreview := .t.

   if ::cAlias != "ARRAY"
     if ::cAlias == "DBFOBJECT"
       nRecNo :=  ::oDbf:RecNo()
     else
       nRecNo := ( ::cAlias )->( RecNo() )
     endif
   endif

   if lPreview
      REPORT oRpt TITLE cTitle PREVIEW ;
         HEADER "Date: " + DToC( Date() ) + ", Time: " + Time() ;
         FOOTER "Page: " + Str( oRpt:nPage, 3 )
   else
      REPORT oRpt TITLE cTitle ;
         HEADER "Date: " + DToC( Date() ) + ", Time: " + Time() ;
         FOOTER "Page: " + Str( oRpt:nPage, 3 )
   endif

      if Empty( oRpt ) .or. oRpt:oDevice:hDC == 0
         return nil
      else
         ::GoTop()
      endif

      for nI = 1 to Len( ::aColumns )
          if !(::aColumns[nI]:lBitMap)

            oRpt:AddColumn( TrColumn():New( { GenHead( ::aColumns, nI ) },, ;
                                        { GenData( ::aColumns, nI ) },,,,,, ;
                  If(ValType(Eval(::aColumns[nI]:bData))$"DN","RIGHT", nil) ;
                                                                ,,,, oRpt ) )

          endif
      next
   ENDREPORT

   oRpt:bSkip = { || oRpt:Cargo := ::Skip( 1 ) }
   oRpt:Cargo = 1

   ACTIVATE REPORT oRpt ;
      WHILE If( ::cAlias == "ARRAY",;
                oRpt:nCounter <= Max( ( Eval( ::bLogicLen, Self ) ) - 1, 1 ),;
                oRpt:Cargo == 1 )

   if ::cAlias != "ARRAY"
     if ::cAlias == "DBFOBJECT"
        ::oDbf:GoTo( nRecNo )
     else
        ( ::cAlias )->( DbGoTo( nRecNo ) )
     endif
   endif

return nil


//----------------------------------------------------------------------------//

METHOD KeyChar( nKey, nFlags )  CLASS TCBrowse

    local cKey    := upper( chr(nKey) )
    local cSeek   := ::cSeek

    if ::bKeyChar == nil
       if ( nKey >= 33 .and. nKey <= 126 ) .or. nKey == K_BS
          if ::cAlias != "ARRAY"
             ::Seek( nKey )
          endif
       endif
    else
        Super:KeyChar( nKey, nFlags )
    endif

return 0

//----------------------------------------------------------------------------//

METHOD PageDown(nLines) CLASS TCBrowse

    ::ResetSeek()
    if ::bSeekChange != Nil
        eval(::bSeekChange)
    endif

        Super:PageDown(nLines)

return nil

//---------------------------------------------------------------------------//

METHOD PageUp(nLines) CLASS TCBrowse

    ::ResetSeek()
    if ::bSeekChange != Nil
        eval(::bSeekChange)
    endif

        Super:PageUp(nLines)

return nil

//---------------------------------------------------------------------------//

METHOD Seek( nKey ) CLASS TCBrowse

    local lFound    := .t.
    local lEof      := .f.
    local lTrySeek  := .t.
    local nRecNo    := 0
    local cSeek     := ::cSeek
    local xSeek     := cSeek
    local oColumn
    local nIdxLen

    if ::nColOrder > 0

        lTrySeek  := .t.

        if ::cOrderType == "C"
           // nIdxLen := Len( Eval( &("{||"+ ordSetFocus()+"}") ) )
           nIdxLen := Len( Eval( &( "{||" + OrdKey(OrdSetFocus()) + "}" ) ) )
        endif

        if nKey == K_BS
            if ::cOrderType == "D"
                cSeek := DateSeek(cSeek,nKey)
            else
                cSeek := Left(cSeek, Len(cSeek) - 1 )
            endif
        else
            if ::cOrderType == "D"
                cSeek := DateSeek(cSeek,nKey)
            elseif ::cOrderType == "N"
              /* only  0..9 */
              if nKey >= 48 .and. nKey <= 57
                cSeek += upper(chr(nKey))
              else
                tone( 500 ,1 )
                lTrySeek  := .f.
              endif
            elseif ::cOrderType == "C"
              if Len(cSeek) < nIdxLen
                cSeek += upper(chr(nKey))
              else
                tone( 500 ,1 )
                lTrySeek  := .f.
              endif
            endif
        endif

        if ::cOrderType == "C"
            xSeek := cSeek
        elseif ::cOrderType == "N"
            xSeek := val(cSeek)
        elseif ::cOrderType == "D"
            xSeek := dtos(ctod(cSeek))
        else
            xSeek := cSeek
        endif

        if ! ( ::cOrderType == "D" .and. len(rtrim(cSeek)) < Len(DtoC(Date())) ) ;
              .and.lTrySeek
            if ::cAlias == "DBFOBJECT"
                nRecNo := ::oDbf:recno()
                lFound := ::oDbf:Seek( xSeek,.t. )
                lEof   := ::oDbf:eof()
                if lEof .or. ( ::cOrderType == "C" .and. ! lFound )
                    ::oDBf:Goto( nRecNo )
                endif
            else
                nRecNo := ( ::cAlias )->( recno() )
                lFound := ( ::cAlias )->( DbSeek( xSeek,.t. ) )
                lEof   := ( ::cAlias )->( eof() )
                if lEof .or. ( ::cOrderType == "C" .and. ! lFound )
                    ( ::cAlias )->( DbGoTo( nRecNo ) )
                endif
            endif
            if  ( ::cOrderType == "C" .and. ! lFound ) .or. lEof
                tone( 500 ,1 )
                if ::cOrderType == "D"
                    DateSeek(cSeek,K_BS)
                else
                    cSeek := Left(cSeek, Len(cSeek) - 1 )
                endif
            else
              // only refresh if record pointer was moved
              if ::cAlias == "DBFOBJECT"
                if nRecNo != ::oDbf:recno()
                  ::ResetBarPos()
                  //::nRowPos := 1
                  ::Refresh()
                endif
              elseif nRecNo != ( ::cAlias )->( recno() )
                  ::ResetBarPos()
                  //::nRowPos := 1
                  ::Refresh()
              endif
            endif
        endif

        ::cSeek := cSeek

        if ::oCtx != Nil
          ::oCtx:Save()
        endif

        if ::bSeekChange != Nil
            eval(::bSeekChange)
        endif

    endif

return nil

//---------------------------------------------------------------------------//

METHOD SetOrder( nColumn ) CLASS TCBrowse

    local lReturn := .f.
    local oColumn := ::aColumns[ nColumn ]

    if !Empty(oColumn:cOrder)
       if ::cAlias != "ARRAY"
           if ::cAlias == "DBFOBJECT"
               ::oDbf:SetOrder( oColumn:cOrder )
              //  ::oDbf:GoTop()
           else
               ( ::cAlias )->( OrdSetFocus( oColumn:cOrder ) )
               // ( ::cAlias )->( DbGoTop() )
           endif

           if Empty(ordSetFocus())
             ::cOrderType := ""
           else
             // ::cOrderType := ValType( Eval( &("{||"+ ordSetFocus()+"}") ) )
             ::cOrderType := ValType( Eval( &("{||"+ OrdKey(OrdSetFocus()) + "}" ) ) )
           endif

           if ::oCtx != Nil
             ::oCtx:ReNew()
           endif

           ::ResetBarPos()

           //::nRowPos := 1
           ::Refresh()
           ::nColOrder := nColumn
           ::ResetSeek()
           ::SetFocus()
           if ::bSeekChange != Nil
               eval(::bSeekChange)
           endif
           lReturn := .t.
       endif
  endif

return lReturn

//---------------------------------------------------------------------------//
static func DateSeek(cSeek,nKey)

    local cChar  := chr(nKey)
    local nSpace := at(" ",cSeek)
    local cTemp  := ""

    /* only  0..9 */
    if nKey >= 48 .and. nKey <= 57
        if nSpace <> 0
            cTemp := left(cSeek,nSpace-1)
            cTemp += cChar
            cTemp += substr(cSeek,nSpace+1,len(cSeek) )
            cSeek := cTemp
        else
            cSeek := cSeek
            tone(500,1)
        endif
    elseif nKey == K_BS
        if nSpace = 4 .or. nSpace = 7
            cTemp := left(cSeek,nSpace-3)
            cTemp += " "
            cTemp += substr(cSeek,nSpace-1,len(cSeek) )
        elseif nSpace == 0
            cTemp := left(cSeek,len(cSeek)-1)
        elseif nSpace == 1
            cTemp := cSeek
        else
            cTemp := left(cSeek,nSpace-2)
            cTemp += " "
            cTemp += substr(cSeek,nSpace,len(cSeek) )
        endif
        cSeek := padr(cTemp,10)
    else
      tone( 500 ,1 )
    endif

return cSeek

//---------------------------------------------------------------------------//
METHOD ResetSeek() CLASS TCBrowse

    local oColumn

    if ::nColOrder > 0
        if ::cOrderType == "D"
            ::cSeek := "  /  /    "
        else
            ::cSeek := ""
        endif
    endif

return ::cSeek

//---------------------------------------------------------------------------//

METHOD ResetBarPos() CLASS TCBrowse

    static bCxKeyNo, bCmKeyNo

    local cRDDName
    local cOrderName , nRecNo
    local lClipMore
    local nLogicPos     // logical record no position within index
    local nLogicLen     // for the future when move into Conatext Class

    if Used()
       cRddName = RddName()
    else
       cRddName = RddSetDefault()
    endif

  if ::cAlias != "ARRAY" .and. ! Empty( ::cAlias )

    if cRDDName == "COMIX" .or. cRDDName == "ADSDBFCDX"
      // must macro the Comix functions since link error if not present
                if cRDDName == "COMIX"
        DEFAULT bCxKeyNo := &("{ | cTag |  cmxKeyNo( cTag ) }")
                else
         DEFAULT bCxKeyNo := &("{ | cTag |  OrdKeyNo( cTag ) }")
                endif

      if (lClipMore := ( Type("cmKeyNo()")=="C".or. ;
                         Type("cmKeyNo()")=="UI" ) )
        DEFAULT bCmKeyNo := &("{ | cTag |  cmKeyNo( cTag ) }")
      endif
    endif

    if ::cAlias == "DBFOBJECT"
      cOrderName := (::oDbf:cAlias)->(ordSetFocus())
      if Empty(cOrderName) // no active index
        nLogicPos := ::oDbf:RecNo()
      elseif cRDDName == "DBFNTX"
        // cure a little quirk in NtxPos if eof gives 0 as LOGICAL pos
        nRecNo := If( ::oDbf:Eof(), ::oDbf:RecNo() - 1, ::oDbf:RecNo())
        nLogicPos :=  NtxPos( (::oDbf:cAlias)->(IndexOrd()), nRecNo )
      elseif cRDDName == "COMIX"
        if lClipMore
          nLogicPos := Eval( bCmKeyNo, cOrderName )
        else
          nLogicPos := Eval( bCxKeyNo, cOrderName )
        endif
      else
        nLogicPos := ::oDbf:RecNo()
      endif
    else
      cOrderName := ( ::cAlias )->( OrdSetFocus() )
      if Empty(cOrderName) // no active index
        nLogicPos := (::cAlias)->(RecNo())
      elseif cRDDName == "DBFNTX"
        // cure a little quirk in NtxPos if eof gives 0 as LOGICAL pos
        nRecNo := If( (::cAlias)->(Eof()), (::cAlias)->(RecNo()) - 1, ;
                       (::cAlias)->(RecNo()) )
        nLogicPos :=  NtxPos( (::cAlias)->(IndexOrd()), nRecNo )
      elseif cRDDName == "COMIX"
        if lClipMore
          nLogicPos := Eval( bCmKeyNo, cOrderName )
        else
          nLogicPos := Eval( bCxKeyNo, cOrderName )
        endif
      else
        nLogicPos := (::cAlias)->(RecNo())
      endif
    endif

    if cRDDName == "ADSDBFCDX"
      ::bLogicLen = &( "{ ||  OrdKeyCount() }" )
   endif

    ::nLen := Eval( ::bLogicLen, Self )

    if ::oVScroll != nil
      ::oVScroll:SetRange( 1, ::nLen )
      ::oVScroll:SetPos( nLogicPos )
    endif

    if (nLogicPos > 0) .and. (nLogicPos < ::nRowPos)
      ::nRowPos := nLogicPos
    endif

  endif

return nil

//---------------------------------------------------------------------------//

METHOD Inspect( cData ) CLASS TCBrowse

   do case
      case cData == "aColumns"
           return { | aColumns | MsgBeep(), aColumns }
   endcase

return nil

//---------------------------------------------------------------------------//
