
:- [math].

%relu_layer([3,2,1,-2,-0.1],2,1,0.5,O).

relu_layer([],_,_,_,[]).
relu_layer([I|Is],Max_Value,Negative_Slope,Threshold,[O|Os]) :-
	atomic(I),
	(I < Threshold -> I1 is I * Negative_Slope + (-Threshold *Negative_Slope);I1 is I),
	(number(Max_Value) -> O is min(I1,Max_Value); O is I1),
	relu_layer(Is,Max_Value,Negative_Slope,Threshold,Os).

    relu_layer([I|Is],Max_Value,Negative_Slope,Threshold,[O|Os]) :-
	is_list(I),
	relu_layer(I,Max_Value,Negative_Slope,Threshold,O),
	relu_layer(Is,Max_Value,Negative_Slope,Threshold,Os).

  
%thresholded_relu_layer([0.138821,0.30971956,0.23123252,0.26585793,0.65178293,0.54254425,0.8526051,0.1260066,0.4059227],0.26,X).
thresholded_relu_layer([],_,[]).
thresholded_relu_layer([I|Is],Theta,[O|Os]) :-
	atomic(I),
	(I > Theta -> O is I;O is 0),
	thresholded_relu_layer(Is,Theta,Os).
thresholded_relu_layer([I|Is],Theta,[O|Os]) :-
	is_list(I),
	thresholded_relu_layer(I,Theta,O),
	thresholded_relu_layer(Is,Theta,Os).
	
%leakyrelu_layer([-0.138821,-0.30971956,0.23123252,0.26585793,0.65178293,0.54254425,0.8526051,0.1260066,0.4059227],0.26,X).
leakyrelu_layer([],_,[]).

leakyrelu_layer([I|Is],Alpha,[O|Os]) :-
	atomic(I),
	(I < 0 -> O is Alpha * I ; O is I),
	leakyrelu_layer(Is,Alpha,Os).

leakyrelu_layer([I|Is],Alpha,[O|Os]) :-
	is_list(I),
	leakyrelu_layer(I,Alpha,O),
	leakyrelu_layer(Is,Alpha,Os).

% Sample data run
% ?- sigmoid_layer([8,5,0],[],Y).
% Y = [0.9996646498695336, 0.9933071490757153, 0.5].
% ?- sigmoid_layer([-8,-5,0],[],Y).
% Y = [0.0003353501304664781, 0.0066928509242848554, 0.5].
% Sigmoid activation function, sigmoid(x) = 1 / (1 + exp(-x)).

sigmoid_layer([],Y,Y).
sigmoid_layer([I|Is],Y0,Y):-
   E is 1 + exp(-I), % calculate denominator term for sigmoid the formula
   O is rdiv(1, rational(E)), % calculate whole value for the sigmoid function
   % format('~5e~n', O),
   S is float(O), % format output as a floating point number
   append(Y0,[S],Ys), 
   sigmoid_layer(Is,Ys,Y).

% Sample data run
% ?- softmax_layer([8,5,0],[],Y).
% Y = [0.9522698261237778, 0.04741072293787844, 0.0003194509383437505].
% Softmax activation function = exp(x) / tf.reduce_sum(exp(x)).

softmax_layer([],Y,Y).
softmax_layer([I|Is],Y0,R2):-
 calc_exp([I|Is],[],Y), % calc exponential for a list elements
 calc_sum([I|Is], 0, Sum),%  calc sum of exponential values for all the list elements
 reduce_sum(Y,Sum,[],R2). % dividing by the normalization to get the valid probabilities, the results
 % that lie between 0 and 1, and they sum to 1.
 
 % calculate reduce sum for a list elements
reduce_sum([],_,Y,Y).
reduce_sum([Y|Ys], Sum1, R1, R2):-
 O is rdiv(rational(Y), rational(Sum1)),
 %format('~5e~n', O),
 S is float(O),
 append(R1, [S], Z),
 reduce_sum(Ys, Sum1, Z, R2).

% calculate sum of all exponetial terms
calc_sum([],Sum1,Sum1).
calc_sum([I|Is], Sum0, Sum):-
 (I > 0 -> O is exp(I); I =:= 0 -> O is 1 ; O is I),
 S is float(O),
 Sum1 is Sum0 + S,
 calc_sum(Is, Sum1, Sum).

% ?- calc_exp_LL([[8,0],[5,0]],[],Y).
% Y = [[2980.9579870417283, 1], [148.4131591025766, 1]].

% calculate exponent of elements in a list of lists
calc_exp_LL([],Y,Y).
calc_exp_LL([[I|Is]|Xs], Y0, Y):-
 calc_exp_SL([I|Is], Y0, L),
 Y = [L|T],    
 calc_exp_LL(Xs, [], T).

%?- calc_exp_SL([5,0],[],Y).
%Y = [148.4131591025766, 1].
% calculate exponent of elements in a list of lists
calc_exp_SL([],Y,Y).
calc_exp_SL([I|Is], Y0, L):-
 (I > 0 -> O is exp(I); I =:= 0 -> O is 1 ; O is I),
 append(Y0, [O], Ys),
 calc_exp_SL(Is, Ys, L).
