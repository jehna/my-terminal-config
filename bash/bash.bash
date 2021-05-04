# Remove Apple's nag of bash being deprecated
export BASH_SILENCE_DEPRECATION_WARNING=1

# Bash prompt message
VISUALIZE_GIT_UNSTAGED_CHANGES="\`if git status > /dev/null 2> /dev/null && ! git diff-files --quiet 2> /dev/null; then echo 🌱; fi\`"
VISUALIZE_ERROR_CODE="\`if [ \$? = 0 ]; then echo 💎; else echo 💩; fi\`"
PS1="${VISUALIZE_GIT_UNSTAGED_CHANGES}${VISUALIZE_ERROR_CODE}[\W]\\$ "
