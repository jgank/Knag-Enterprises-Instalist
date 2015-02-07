Pod::Spec.new do |s|
  s.name         = 'Impulse Shopper'
  s.version      = '<#Project Version#>'
  s.license      =  :type => '<#License#>'
  s.homepage     = '<#Homepage URL#>'
  s.authors      =  '<#Author Name#>' => '<#Author Email#>'
  s.summary      = '<#Summary (Up to 140 characters#>'

# Source Info
  s.platform     =  :ios, '<#iOS Platform#>'
  s.source       =  :git => '<#Github Repo URL#>', :tag => '<#Tag name#>'
  s.source_files = '<#Resources#>'
  s.framework    =  '<#Required Frameworks#>'

  s.requires_arc = true
  
# Pod Dependencies
  s.dependencies =	pod 'SDWebImage', '~>3.6'

end