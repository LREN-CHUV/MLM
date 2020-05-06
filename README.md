# MLM
Mulivariate analysis for Neuroimaging data.
 Multivariate Methods. General multivariate tool. 
 Contains different procedures to explore MRI or PET DATA
 The standard way of using the MM package is to first perform a standard spm analysis,
 that will provide a first apriori model and the corresponding estimated parameters
 and residual sum of square images. As the temporal filter or the normalisation chosen 
 is of importance, please keep in mind the parameters used for a meaningful interpretation
 of your MM results.
 
 MM embeds the concept of several spatial space such that if the regression model
 is performed separately on several subjects (1..N) or regions of interest have the same 
 temporal space, MM allows you to consider your data as a matrix with dimension
 common-time-dim X (subject1-space-dim + subject2-space-dim +  ... + subjectN-space-dim)
 In such a case, the result of the analysis for the first component is one time
 dimension eigen vector and one space dimension vector with size :
 (subject1-space-dim + subject2-space-dim +  ... + subjectN-space-dim), 
 which can also be considered as one eigenimage per subject (or region of interest).
  
 More often, the MM is performed on a matrix with dimension
 (subject1-time-dim + subject2-time-dim +  ... + subjectN-time-dim) X common-space-dim
 
 1) SVD analysis:   Given image files and a contrast of a general linear model, 
 		     this procedure  perform PCA analysis on the projected data 
		     in the sub-space defined by the contrast. 
		     orthogonal projection allow to study the residual part of a model. 
 		     
 2) MLM analysis: Given Beta images and a contrast of a general linear model this procedure
  		    allow to study the relatiom between the data and the model.
 		    MLM is adapted from Worsley et al (1997).
 
----- References ----------
 MLM : Worsley KJ, Poline JB, Friston KJ, Evans AC.
 "Characterizing the response of PET and fMRI data using multivariate linear models."
 Neuroimage 1997 Nov;6(4):305-19  
 SVD :  K.J. Friston, J.-B. Poline, S. Strother, A.P. Holmes, C.D. Frith, et
 R.S.J.  Frackowiak, "A multivariate analysis of PET activation
 studies" Human brain mapping. 4:140-151, 1996.

================================================================================
 CREDITS

 This package was developped by Ferath Kherif primarily
 
 A number of functions used in the toolbox belong to the SPM core package from the
 Wellcome Department of Cognitive Neurology, (also distributed under GNU General 
 Public License). See www.fil.ion.ucl.ac.uk

 COPYING / DISTRIBUTING

 You can redistribute it and/or modify it under the terms of the GNU General Public
 License version 2 as published by the Free Software Foundation, which is displayed 
 in the accompanying COPYING file. See the GNU General Public License for more
 details. 

 Please redirect requests for the toolbox to us. For bugs, remarks, additions, 
 etc, please contact 
                          ferath.kherif@chuv.ch
 
 If you are using this material for publication, please see with us how you can 
 acknowledge our work.

================================================================================
 WARNING : THIS SOFTWARE IS DISTRIBUTED FREE WITHOUT ANY GUARANTY ! 
================================================================================
================================================================================
-  Copyright (C)  LREN

================================================================================
 Uptaed version 2019

