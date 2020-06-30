import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import VotePopup from './votePopup';

describe('<VotePopup />', () => {
  test('it should mount', () => {
    render(<VotePopup />);
    
    const VotePopup = screen.getByTestId('VotePopup');

    expect(VotePopup).toBeInTheDocument();
  });
});