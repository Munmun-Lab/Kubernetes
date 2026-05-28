cd /home directory
echo "alias k='kubectl'" >> ~/.bashrc
echo "alias kgp='kubectl get pods'" >> ~/.bashrc
echo "alias kgs='kubectl get svc'" >> ~/.bashrc
echo "alias kgn='kubectl get nodes'" >> ~/.bashrc
echo "alias kga='kubectl get all'" >> ~/.bashrc
echo "alias kcd='kubectl config view --minify --output 'jsonpath={.clusters[0].name}''" >> ~/.bashrc
echo "alias kctx='kubectl config current-context'" >> ~/.bashrc
echo "alias kns='kubectl config view --minify --output 'jsonpath={.contexts[0].context.namespace}''" >> ~/.bashrc
source ~/.bashrc
echo "Aliases for kubectl have been set up. You can now use 'k' instead of 'kubectl' and other shortcuts for common commands."      


