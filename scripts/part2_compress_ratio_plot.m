%   A d d e d   t h e   p a t h   o f   f u n c t i o n s  
 a d d p a t h ( ' . / f u n c t i o n s ' ) ;  
  
 i n p u t _ f o l d e r   =   ' . . / v i d e o _ d a t a / ' ;  
 f r a m e _ f i l e s   =   d i r ( f u l l f i l e ( i n p u t _ f o l d e r ,   ' * . j p g ' ) ) ;  
 n u m _ f r a m e s   =   l e n g t h ( f r a m e _ f i l e s ) ;  
 %   U n c o m p r e s s e d   v i d e o   s i z e   i n   b i t s :   4 8 0   x   3 6 0   p i x e l s   x   2 4   b i t s   x   1 2 0   f r a m e s  
 u n c o m p r e s s e d _ b i t s   =   4 8 0   *   3 6 0   *   2 4   *   1 2 0 ;    
 %   T e s t   G O P   s i z e s   f r o m   1   t o   3 0  
 g o p s   =   1 : 3 0 ;  
 %   S t o r e s   b i t   s i z e s   f o r   e a c h   G O P  
 c o m p r e s s e d _ b i t s   =   z e r o s ( s i z e ( g o p s ) ) ;  
  
 f o r   i d x   =   1 : n u m e l ( g o p s )  
         g o p _ s i z e   =   g o p s ( i d x ) ;    
         %   C o m p r e s s   u s i n g   i m p r o v e d   a l g o r i t h m   ( i n c l u d e s   m o t i o n   e s t i m a t i o n )  
         i m p r o v e d _ c o m p r e s s ;              
         %   M e a s u r e   o u t p u t   f i l e   s i z e  
         o u t n a m e   =   s p r i n t f ( ' . . / o u t p u t s / r e s u l t _ i m p r o v e d _ g o p % 0 2 d . b i n ' ,   g o p _ s i z e ) ;  
         i n f o   =   d i r ( o u t n a m e ) ;  
         c o m p r e s s e d _ b i t s ( i d x )   =   i n f o . b y t e s   *   8 ;     %   b i t s  
 e n d  
  
 %   C o m p u t e s   a n d   p l o t s   c o m p r e s s i o n   r a t i o  
 r a t i o   =   c o m p r e s s e d _ b i t s   . /   u n c o m p r e s s e d _ b i t s ;  
 f i g u r e ;  
 p l o t ( g o p s ,   r a t i o ,   ' - o ' ,   ' L i n e W i d t h ' ,   1 . 5 ) ;  
 x l a b e l ( ' G O P   S i z e ' ) ;  
 y l a b e l ( ' C o m p r e s s e d   B i t s   /   U n c o m p r e s s e d   B i t s ' ) ;  
 t i t l e ( ' I m p r o v e d   C o m p r e s s i o n   R a t i o   v s   G O P   S i z e ' ) ;  
 g r i d   o n ;  
 