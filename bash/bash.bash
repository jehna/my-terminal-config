# Remove Apple's nag of bash being deprecated
export BASH_SILENCE_DEPRECATION_WARNING=1

# Prompt that was cool in 2020
PS1="\`if [ \$? = 0 ]; then echo 💎; else echo 💩; fi\`[\W]\\$ "