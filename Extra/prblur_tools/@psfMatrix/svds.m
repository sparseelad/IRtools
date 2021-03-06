function varargout = svds( A, b, k, kronTerms )
%
%       [U, S, V] = svd(A);
%       [U, S, V] = svd(A, b);
%       [U, S, V] = svd(A, b, k);
%       [U, S, V] = svd(A, b, k, kronTerms);
%
%  Overloaded SVD method for psfMatrix objects. This computes the SVD
%  componets for a fixed rank.
%
%  Input: 
%    A is a psfMatrix
%
%  Optional Input:
%    b is a blurred image.  Since A often uses a compact storage
%      scheme, this is sometimes needed to determine "real size" 
%      of the matrix.
%    k is a positive integer indicating the number of largest singular 
%      values and corresponding vectors to compute. 
%      Default value is k = 10.
%      
%
%  Output:
%    This depends on the type of blur, and boundary conditions.
%    * If A.boundary = 'periodic', then U and V are
%      transformMatrix objects, with U.transform V.transform = 'fft'
%      S is a column vector containing the eigenvalues of A.
%    * If A.boundary = 'reflexive', and A is symmetric, then
%      U and V are transformMatrix objects, with
%      U.transform = V.transform = 'dct'
%      S is a column vector containing the eigenvalues of A.
%    * In all other cases, a Kronecker product approximation of
%      A is first computed, and U and V are then kronMatrix objects.
%      S is a column vector containing the singular values of A
%      (they are not sorted, though).
%

%  J. Nagy  1/21/16


switch A.type
  case 'invariant'
    P = A.psf;
    P1 = P.image;, c = P.center;
    PSF = P1{1};,  center = c{1};

    if (nargin == 2)
      PSF = padarray(PSF, size(b) - size(PSF), 'post');
    else
      b = PSF;  % This is used to define correct dimensions only.
    end
  
    switch A.boundary
    case 'periodic'
      [U, S, V] = fft_svd(PSF, center);
    case 'reflexive'
      if issymmetric(A)
         [U, S, V] = dct_svd(PSF, center);
      else
         [U, S, V] = svd_approx( kronApprox(A, b) );
      end
    case 'zero'
      [U, S, V] = svd_approx( kronApprox(A, b) );
    otherwise
      error('Invalid boundary condition')
    end
    
  case 'variant'
    [U, S, V] = svd_approx( kronApprox(A, b) );
    
  otherwise
    error('invalid matrix type')
end

if nargout == 1
  varargout{1} = S;
elseif nargout == 3
  varargout{1} = U;
  varargout{2} = S;
  varargout{3} = V;
else
  error('In correct number of output variables')
end

