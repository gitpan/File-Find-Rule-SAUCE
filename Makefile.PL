use ExtUtils::MakeMaker;
WriteMakefile(
              'NAME' => 'File::Find::Rule::SAUCE',
              'VERSION_FROM' => 'SAUCE.pm',
              'PREREQ_PM' => {
                              'File::Find::Rule' => 0,
                              'File::SAUCE' => 0.03
                             },
               );