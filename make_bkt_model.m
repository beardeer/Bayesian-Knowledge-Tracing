function bnet = make_bkt_model(N)

% topology is defined in a directed acyclic graph
dag = zeros(N,N);

% knowledge nodes (latent)
K=1:N/2;
% question nodes (observable)
Q=(N/2+1):N;

% connect K nodes
for i = 1:(N/2-1)
    dag(K(i),K(i+1)) = 1;
end

% connect K to Q
for i = 1:(N/2)
    dag(K(i),Q(i)) = 1;
end 

% equivalence classes specify which nodes share a single CPT
eclass = zeros(1,N);

% K1 gets a separate eclass because it has no parent (different CPT dimension)
% K1 CPT contains the prior probability
eclass(1) = 1;

% all the other knowledge nodes share the same transition probabilities
eclass(K(2:end)) = 2;

% all question nodes share the same emission probabilities
eclass(Q) = 3;

% observed variables
obs = (N/2+1):N;

% all nodes modeled as binary variables
node_sizes = 2 * ones(1,N);

% all nodes are discrete variables
discrete_nodes = 1:N;

bnet = mk_bnet(dag,node_sizes, 'discrete', discrete_nodes, 'observed', obs, 'equiv_class', eclass);

